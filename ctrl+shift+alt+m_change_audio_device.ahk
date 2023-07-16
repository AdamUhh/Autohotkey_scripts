#Requires AutoHotkey v2.0-a136-feda41f4
; ? Source: https://www.autohotkey.com/boards/viewtopic.php?f=76&t=49980

; http://www.daveamenta.com/2011-05/programmatically-or-command-line-change-the-default-sound-playback-device-in-windows-7/
; https://web.archive.org/web/20190317012739/http://www.daveamenta.com/2011-05/programmatically-or-command-line-change-the-default-sound-playback-device-in-windows-7/

#SingleInstance force
#NoTrayIcon

List := EnumAudioEndpoints()

; ? Initially used to show the EXACT names of the IO devices
; Devices := ""
; for Device in List
;     Devices .= Format("{} ({})`n`n", Device["Name"], Device["ID"])
; MsgBox(Devices)

Device1 := "LG HDR WFHD (HD Audio Driver for Display Audio)" ; ? My Speaker
Device2 := "Realtek HD Audio 2nd output (Realtek(R) Audio)" ; ? My Headphones

SetDefaultEndpoint(GetDeviceID(List, Device2)) ; ? Sets default device to headphones when it runs
selectedDevice := 2

^<+!m::
    {
        global selectedDevice
        if (selectedDevice = 1) {
            SetDefaultEndpoint(GetDeviceID(List, Device2))
            selectedDevice := 2
        }
        else {
            SetDefaultEndpoint(GetDeviceID(List, Device1))
            selectedDevice := 1
        }
        ; SetDefaultEndpoint(GetDeviceID(List, "Microphone (Realtek(R) Audio)")) ; ? Microphone (I don't need to change this)

        Return
    }

    /*
        Generates a collection of audio endpoint devices that meet the specified criteria.
        Parameters:
            DataFlow:
                The data-flow direction for the endpoint devices in the collection.
                0   Audio rendering stream. Audio data flows from the application to the audio endpoint device, which renders the stream.
                1   Audio capture stream. Audio data flows from the audio endpoint device that captures the stream, to the application.
                2   Audio rendering or capture stream. Audio data can flow either from the application to the audio endpoint device, or from the audio endpoint device to the application.
            StateMask:
                The state or states of the endpoints that are to be included in the collection.
                1   Active. The audio adapter that connects to the endpoint device is present and enabled. In addition, if the endpoint device plugs into a jack on the adapter, then the endpoint device is plugged in.
                2   Disabled. The user has disabled the device in the Windows multimedia control panel (Mmsys.cpl).
                4   Not present. The audio adapter that connects to the endpoint device has been removed or disabled.
                8   Unplugged. The audio adapter that contains the jack for the endpoint device is present and enabled, but the endpoint device is not plugged into the jack. Only a device with jack-presence detection can be in this state.
        Return value:
            Returns an array of Map objects with the following keys:
            ID      Endpoint ID string that identifies the audio endpoint device.
            Name    The friendly name of the endpoint device.
    */
    EnumAudioEndpoints(DataFlow := 2, StateMask := 1)
    {
        List := []

        ; IMMDeviceEnumerator interface.
        ; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immdeviceenumerator
        IMMDeviceEnumerator := ComObject("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}")

        ; IMMDeviceEnumerator::EnumAudioEndpoints method.
        ; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nf-mmdeviceapi-immdeviceenumerator-enumaudioendpoints
        ComCall(3, IMMDeviceEnumerator, "UInt", DataFlow, "UInt", StateMask, "UPtrP", &IMMDeviceCollection:=0)

        ; IMMDeviceCollection::GetCount method.
        ; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nf-mmdeviceapi-immdevicecollection-getcount
        ComCall(3, IMMDeviceCollection, "UIntP", &DevCount:=0) ; Retrieves a count of the devices in the device collection.

        loop DevCount
        {
            List.Push(Device := Map())

            ; IMMDeviceCollection::Item method.
            ; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nf-mmdeviceapi-immdevicecollection-item
            ComCall(4, IMMDeviceCollection, "UInt", A_Index-1, "UPtrP", &IMMDevice:=0)

            ; IMMDevice::GetId method.
            ; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nf-mmdeviceapi-immdevice-getid
            ComCall(5, IMMDevice, "PtrP", &pBuffer:=0)
            Device["ID"] := StrGet(pBuffer)
            DllCall("Ole32.dll\CoTaskMemFree", "UPtr", pBuffer)

            ; MMDevice::OpenPropertyStore method.
            ; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nf-mmdeviceapi-immdevice-openpropertystore
            ComCall(4, IMMDevice, "UInt", 0x00000000, "UPtrP", &IPropertyStore:=0)

            Device["Name"] := GetDeviceProp(IPropertyStore, "{A45C254E-DF1C-4EFD-8020-67D146A850E0}", 14)

            ObjRelease(IPropertyStore)
            ObjRelease(IMMDevice)
        }

        ObjRelease(IMMDeviceCollection)

        return List
    }

    /*
        Set default audio render endpoint.
        Role:
            0x1   Default Device.
            0x2   Default Communication Device.
    */
    SetDefaultEndpoint(DeviceID, Role := 3)
    {
        ; Undocumented COM-interface IPolicyConfig.
        IPolicyConfig := ComObject("{870AF99C-171D-4F9E-AF0D-E63Df40c2BC9}", "{F8679F50-850A-41CF-9C72-430F290290C8}")
        if (Role & 0x1)
            ComCall(13, IPolicyConfig, "Str", DeviceID, "Int", 0) ; Default Device
        if (Role & 0x2)
            ComCall(13, IPolicyConfig, "Str", DeviceID, "Int", 2) ; Default Communication Device
    }

    /*
        Device Properties (Core Audio APIs)
        https://docs.microsoft.com/en-us/windows/win32/coreaudio/device-properties

        026E516E-B814-414B-83CD-856D6FEF4822, 2   The friendly name of the audio adapter to which the endpoint device is attached.
        A45C254E-DF1C-4EFD-8020-67D146A850E0, 2   The device description of the endpoint device.
        A45C254E-DF1C-4EFD-8020-67D146A850E0,14   The friendly name of the endpoint device.
    */
    InitDeviceProp(clsid, n)
    {
        clsid := CLSIDFromString(clsid, Buffer(16+4))
        NumPut("Int", n, clsid, 16)
        return clsid
    }

    GetDeviceProp(ptr, clsid, n)
    {
        ; IPropertyStore::GetValue method.
        ; https://docs.microsoft.com/en-us/windows/win32/api/propsys/nf-propsys-ipropertystore-getvalue
        ComCall(5, ptr, "Ptr", InitDeviceProp(clsid, n), "Ptr", pvar := PropVariant())
        return String(pvar)
    }

    GetDeviceID(list, name)
    {
        for device in list
            if InStr(device["Name"], name)
                return device["ID"]
        throw
    }

    CLSIDFromString(Str, Buffer := 0)
    {
        if (!Buffer)
            Buffer := Buffer(16)
        DllCall("Ole32\CLSIDFromString", "Str", Str, "Ptr", Buffer, "HRESULT")
        return Buffer
    }

    class PropVariant
    {
        __New()
        {
            this.buffer := Buffer(A_PtrSize == 4 ? 16 : 24)
            this.ptr := this.buffer.ptr
            this.size := this.buffer.size
        }

        __Delete()
        {
            DllCall("Ole32\PropVariantClear", "Ptr", this.ptr, "HRESULT")
        }

        ToString()
        {
            return StrGet(NumGet(this.ptr, 8, "UPtr")) ; LPWSTR PROPVARIANT.pwszVal
        }
    }