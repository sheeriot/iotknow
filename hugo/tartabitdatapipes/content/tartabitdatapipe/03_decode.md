+++
title = 'Create Decode Trigger (Tartabit)'
date = 2024-05-10
draft = false
+++

# Create Decode Trigger (Tartabit)

DocSet:

* [Overview](../00_overview)
* [Setup LNS Service](../01_lns)
* [Create Post Trigger](../02_post)
* [Create Decode Trigger](../03_decode) &nbsp;&nbsp; **&lt;- you are here**
* [Create Save Trigger](../04_save)
* [Setup InfluxDB Service](../05_influxdb)

Purpose of this page:

* Setup the Tartabit IoT-Bridge **trigger** to decode and record the device payload.

## Setup Tartabit Trigger for Decoding Device Payload

This page provides details to complete the following tasks:

* create the Tartabit IoT-Bridge **Decode** trigger to decode the device paylod as received from the **Post** trigger
* integrate a `Decoder(bytes,port)` function for unpacking the payload
* implement recording routines to store decoded sensor readings and messages with the `field_set`
* call the **Save** trigger with the `exec.now` function

![Tartabit Data Pipeline - Components](../diagrams/structurizr-1-tartabit_CONTAINERS.png)

## Create the Decode Trigger

The **Decode** trigger will receive the device payload from the **Post** trigger, and unpack the message and readings for storage (save). from the Everynet LNS. Here you can see the trigger is defined to filter by HTTP Post on the service and on body.type == uplink

![Tartabit - Decode Trigger](../images/tartabit-trigger-decode.png)

## Decode Trigger Code

This section provides the code used for the Radio Bridge sensors used in this example.

```javascript
// Decode the Payload from Base64 using Byte Buffer
// Get the port from Telem
var field_set = event.data.data.field_set
var decode_set = event.data.data.decode_set
var port = decode_set.port
var payload = decode_set.payload

if (payload != null) {

    var buffer = convert.b64ToBin(payload)
    var buff_type = typeof buffer
    var decoded_payload = Decoder(buffer, port)

    log.trace('decoded_payload:\n' + JSON.stringify(decoded_payload))

    // ** Stored Decoded decoded_payload in field_set
    // Use standard Field names. TBD

    // RadioBridge Voltmeter - derived values for this sensor
    field_set.message_counter = decoded_payload.data.Counter
    // log.trace("protocol:" +decoded_payload.data.Protocol)
    field_set.message_type = decoded_payload.data.Type;
    // pickup per Message_Type parameters

    if (decoded_payload.data.Type == "RESET") {
        field_set.message_type  += ":" + decoded_payload.data.Reset.Device
        field_set.message_type  += ":" + "HW_" + decoded_payload.data.Reset.Hardware
        field_set.message_type  += ":" + "FW_" + decoded_payload.data.Reset.Firmware
    }

    if (decoded_payload.data.Type == "SUPERVISORY") {
        field_set.battery_voltage = parseFloat(decoded_payload.data.Supervisory.Battery)
        field_set.message_type += ":" + "Counter-" + decoded_payload.data.Counter 
        field_set.message_type += ":" + "TamperState-" + decoded_payload.data.Supervisory.TamperState
        field_set.message_type += ":" + "TamperSinceLastReset-" + decoded_payload.data.Supervisory.TamperSinceLastReset
        field_set.message_type += ":" + "Accumulation-" + decoded_payload.data.Supervisory.Accumulation
        field_set.message_type += ":" + "BatteryLow-" + decoded_payload.data.Supervisory.BatteryLow
        field_set.message_type += ":" + "ErrorWithLastDownlink-" + decoded_payload.data.Supervisory.ErrorWithLastDownlink
        field_set.message_type += ":" + "RadioCommError-" + decoded_payload.data.Supervisory.RadioCommError
    }
    if (decoded_payload.data.Type == "VOLTMETER") {
        field_set.volts1 = decoded_payload.data.Voltmeter.Voltage
        field_set.message_type  += ":" + decoded_payload.data.Voltmeter.Event
         field_set.message_type  += ":" + "Volts " + decoded_payload.data.Voltmeter.Voltage
    }
    if (decoded_payload.data.Type == "ULTRASONIC") {
        field_set.message_type  += ":" + decoded_payload.data.Ultrasonic.Event
        field_set.message_type  += ":" + decoded_payload.data.Ultrasonic.Distance
        field_set.level_distance = decoded_payload.data.Ultrasonic.Distance
    }
    if (decoded_payload.data.Type == "TAMPER") {
        field_set.message_type  += ":" + decoded_payload.data.Tamper.Event
    }
    if (decoded_payload.data.Type == "DOWNLINKACK") {
        field_set.message_type += ":" + "Counter-" + decoded_payload.data.Counter
        field_set.message_type += ":" + decoded_payload.data.DownlinkACK.Event
    }
    if (decoded_payload.data.Type == "LINK QUALITY") {
        field_set.message_type += ":" + "Counter-" + decoded_payload.data.Counter
        field_set.message_type += ":" + "RSSI " + decoded_payload.data.Link_Quality.RSSI
        field_set.message_type += ":" + "SNR " + decoded_payload.data.Link_Quality.SNR
        field_set.message_type += ":" + "Subband  " + decoded_payload.data.Link_Quality.Subband
    }
}

log.trace('field_set:\n' + JSON.stringify(field_set))

// send to save
exec.now('usfieldtest-radiobridge-save', {
    tag_set: event.data.data.tag_set,
    field_set: field_set
})


// Payload Decoder Function - Radio Bridge
// Source:
// https://github.com/RadioBridge/Packet-Decoder/blob/master/radio_bridge_packet_decoder.js

//     RADIO BRIDGE PACKET DECODER v1.2
// (c)2022 Radio Bridge USA by John Sheldon

////////////////////////////////////////////
// NOTE: This decoder is not officially supported and is provided "as-is" as a developer template.
// Multitech / Radio Bridge make no guarantees about use of this decoder in a production environment.
////////////////////////////////////////////

// SUPPORTED SENSORS:
//   RBS301 Series
//   RBS304 Series
//   RBS305 Series
//   RBS306 Series (except RBS306-VSHB & RBS306-CMPS)

// VERSION 1.2 NOTES:
//   Changed output to JSON
//   Various bug fixes for decodes
//   Compatible with TTNv3
//   Bug fix for thermocouple temperature to 2 decimal places


// The generic decode function called by one of the above network server specific callbacks
function Decoder(bytes, port) {
        // General defines used in decode
    //  Common Events
    var RESET_EVENT               = "00";
    var SUPERVISORY_EVENT         = "01";
    var TAMPER_EVENT              = "02";
    var LINK_QUALITY_EVENT        = "FB";
    var RATE_LIMIT_EXCEEDED_EVENT = "FC"; //deprecated
    var TEST_MESSAGE_EVENT        = "FD"; //deprecated
    var DOWNLINK_ACK_EVENT        = "FF";

    //  Device-Specific Events
    var DOOR_WINDOW_EVENT         = "03";
    var PUSH_BUTTON_EVENT         = "06";
    var CONTACT_EVENT             = "07";
    var WATER_EVENT               = "08";
    var TEMPERATURE_EVENT         = "09";
    var TILT_EVENT                = "0A";
    var ATH_EVENT                 = "0D";
    var ABM_EVENT                 = "0E";
    var TILT_HP_EVENT             = "0F";
    var ULTRASONIC_EVENT          = "10";
    var SENSOR420MA_EVENT         = "11";
    var THERMOCOUPLE_EVENT        = "13";
    var VOLTMETER_EVENT           = "14";
    var CUSTOM_SENSOR_EVENT       = "15";
    var GPS_EVENT                 = "16";
    var HONEYWELL5800_EVENT       = "17";
    var MAGNETOMETER_EVENT        = "18";
    var VIBRATION_LB_EVENT        = "19";
    var VIBRATION_HB_EVENT        = "1A";
    // data structure which contains decoded messages
    var decode = { 
        data: { 
                Event: "UNDEFINED" 
            }
        };
    // The first byte contains the protocol version (upper nibble) and packet counter (lower nibble)

    ProtocolVersion = (bytes[0] >> 4) & 0x0f;
    // decode.ProtocolVersion = ProtocolVersion;    

    PacketCounter = bytes[0] & 0x0f;
    // decode.PacketCounter = PacketCounter;

    // the event type is defined in the second byte
    PayloadType = Hex(bytes[1]);

    // decode.PayloadTypeHex = PayloadType;

    // the rest of the message decode is dependent on the type of event
    switch (PayloadType) {

        // ==================    RESET EVENT    ====================
        case RESET_EVENT:
            // third byte is device type, convert to hex format for case statement 
            EventType = Hex(bytes[2]);

            // device types are enumerated below
            switch (EventType) {
                case "01": DeviceType = "Door/Window Sensor"; break;
                case "02": DeviceType = "Door/Window High Security"; break;
                case "03": DeviceType = "Contact Sensor"; break;
                case "04": DeviceType = "No-Probe Temperature Sensor"; break;
                case "05": DeviceType = "External-Probe Temperature Sensor"; break;
                case "06": DeviceType = "Single Push Button"; break;
                case "07": DeviceType = "Dual Push Button"; break;
                case "08": DeviceType = "Acceleration-Based Movement Sensor"; break;
                case "09": DeviceType = "Tilt Sensor"; break;
                case "0A": DeviceType = "Water Sensor"; break;
                case "0B": DeviceType = "Tank Level Float Sensor"; break;
                case "0C": DeviceType = "Glass Break Sensor"; break;
                case "0D": DeviceType = "Ambient Light Sensor"; break;
                case "0E": DeviceType = "Air Temperature and Humidity Sensor"; break;
                case "0F": DeviceType = "High-Precision Tilt Sensor"; break;
                case "10": DeviceType = "Ultrasonic Level Sensor"; break;
                case "11": DeviceType = "4-20mA Current Loop Sensor"; break;
                case "12": DeviceType = "Ext-Probe Air Temp and Humidity Sensor"; break;
                case "13": DeviceType = "Thermocouple Temperature Sensor"; break;
                case "14": DeviceType = "Voltage Sensor"; break;
                case "15": DeviceType = "Custom Sensor"; break;
                case "16": DeviceType = "GPS"; break;
                case "17": DeviceType = "Honeywell 5800 Bridge"; break;
                case "18": DeviceType = "Magnetometer"; break;
                case "19": DeviceType = "Vibration Sensor - Low Frequency"; break;
                case "1A": DeviceType = "Vibration Sensor - High Frequency"; break;
                default:   DeviceType = "Device Undefined"; break;
            }

            // the hardware version has the major version in the upper nibble, and the minor version in the lower nibble
            HardwareVersion = ((bytes[3] >> 4) & 0x0f) + "." + (bytes[3] & 0x0f);
            // the firmware version has two different formats depending on the most significant bit
            FirmwareFormat = (bytes[4] >> 7) & 0x01;

            log.trace('HardwareVersion: ' + HardwareVersion + ', FirmwareFormat: ' + FirmwareFormat);

            // decode.HardwareVersion = HardwareVersion;
            // decode.FirmwareFormat = FirmwareFormat;

            // FirmwareFormat of 0 is old format, 1 is new format
            // old format is has two sections x.y
            // new format has three sections x.y.z

            if (FirmwareFormat === 0)
                FirmwareVersion = bytes[4] + "." + bytes[5];
            else
                FirmwareVersion = ((bytes[4] >> 2) & 0x1F) + "." + ((bytes[4] & 0x03) + ((bytes[5] >> 5) & 0x07)) + "." + (bytes[5] & 0x1F);

            decode = {data: { 
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "RESET", 
              Reset: {
                Device: DeviceType,
                Firmware: FirmwareVersion,
                Hardware: HardwareVersion
            }}};
            break;

        // ================   SUPERVISORY EVENT   ==================
        case SUPERVISORY_EVENT:
            // note that the sensor state in the supervisory message is being depreciated, so those are not decoded here
            // battery voltage is in the format x.y volts where x is upper nibble and y is lower nibble
            BatteryLevel = ((bytes[4] >> 4) & 0x0f) + "." + (bytes[4] & 0x0f);
            // the accumulation count is a 16-bit value
            AccumulationCount = (bytes[9] * 256) + bytes[10];
            // decode bits for error code byte
            TamperSinceLastReset = (bytes[2] >> 4) & 0x01;
            CurrentTamperState = (bytes[2] >> 3) & 0x01;
            ErrorWithLastDownlink = (bytes[2] >> 2) & 0x01;
            BatteryLow = (bytes[2] >> 1) & 0x01;
            RadioCommError = bytes[2] & 0x01;

            decode = {data: { 
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "SUPERVISORY", 
              Supervisory: {
                Accumulation: AccumulationCount,
                TamperSinceLastReset: TamperSinceLastReset,
                TamperState: CurrentTamperState,
                ErrorWithLastDownlink: ErrorWithLastDownlink,
                BatteryLow: BatteryLow,
                RadioCommError: RadioCommError,
                Battery: BatteryLevel + "V"
            }}};
            break;

        // ==================   TAMPER EVENT    ====================
        case TAMPER_EVENT:
            EventType = bytes[2];
            // tamper state is 0 for open, 1 for closed
            if (EventType == 0)
                TamperEvent = "Open";
            else
                TamperEvent = "Closed";

            decode = {data: { 
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "TAMPER", 
              Tamper: {
                Event: TamperEvent
            }}};
            break;

        // ==================   LINK QUALITY EVENT    ====================
        case LINK_QUALITY_EVENT:
            CurrentSubBand = bytes[2];
            RSSILastDownlink = (-256 + bytes[3]); // RSSI is always negative
            SNRLastDownlink = bytes[4];

            decode = {data: { 
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "LINK QUALITY",
              Link_Quality: {
                RSSI: RSSILastDownlink,
                SNR: SNRLastDownlink,
                Subband: CurrentSubBand,
            }}};
            //log.trace('LINK_QUALITY_EVENT:\n' + JSON.stringify(decode));
            break;

        // ==================   RATE LIMIT EXCEEDED EVENT    ====================
        //case RATE_LIMIT_EXCEEDED_EVENT:
            // this feature is depreciated so it is not decoded here
            // decoded.Message = "Event: Rate Limit Exceeded. Depreciated Event And Not Decoded Here";
            // break;

        // ==================   TEST MESSAGE EVENT    ====================
        // case TEST_MESSAGE_EVENT:
            // this feature is depreciated so it is not decoded here
            // decoded.Message = "Event: Test Message. Depreciated Event And Not Decoded Here";
            // break;

        // ================  DOOR/WINDOW EVENT  ====================
        case DOOR_WINDOW_EVENT:
            EventType = bytes[2];
            // 0 is closed, 1 is open
            if (EventType == 0)
                DoorEvent = "Closed";
            else
                DoorEvent = "Open";
            decode = {data: { 
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "DOOR/WINDOW",
              DoorWindow: {
                Event: DoorEvent,
            }}};
            break;

        // ===============  PUSH BUTTON EVENT   ===================
        case PUSH_BUTTON_EVENT:
            EventType = Hex(bytes[2]);
            switch (EventType) {
                // 01 and 02 used on two button
                case "01": ButtonEvent = "Button 1"; break;
                case "02": ButtonEvent = "Button 2"; break;
                // 03 is single button
                case "03": ButtonEvent = "Button"; break;
                // 12 when both buttons pressed on two button
                case "12": ButtonEvent = "Both Buttons"; break;
                default:   ButtonEvent = "Undefined"; break;
            }
            SensorState = bytes[3];
            switch (SensorState) {
                case 0:  ButtonState = "Pressed"; break;
                case 1:  ButtonState = "Released"; break;
                case 2:  ButtonState = "Held"; break;
                default: ButtonState = "Undefined"; break;
            }
            
            decode = {data: { 
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "BUTTON",
              Button: {
                Event: ButtonEvent,
                State: ButtonState,
            }}};
            break;

        // =================   CONTACT EVENT   =====================
        case CONTACT_EVENT:
            EventType = bytes[2];
            // if state byte is 0 then shorted, if 1 then opened
            if (EventType == 0)
                ContactEvent = "Contacts Shorted";
            else
                ContactEvent = "Contacts Opened";
                       
            decode = {data: {
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "CONTACT",
              Contact: {
                Event: ContactEvent,
            }}};
            break;

        // ===================  WATER EVENT  =======================
        case WATER_EVENT:
            EventType = bytes[2];
            if (EventType == 0)
                WaterEvent = "Water Present";
            else
                WaterEvent = "Water Not Present";

            WaterRelative = bytes[3];
            decode = {data: {
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "WATER",
              Water: {
                Event: WaterEvent,
                Relative: WaterRelative,
            }}};
            break;

        // ================== TEMPERATURE EVENT ====================
        case TEMPERATURE_EVENT:
            EventType = bytes[2];
            switch (EventType) {
                case 0:  TempEvent = "Periodic Report"; break;
                case 1:  TempEvent = "Temperature Over Upper Threshold"; break;
                case 2:  TempEvent = "Temperature Under Lower Threshold"; break;
                case 3:  TempEvent = "Temperature Report-on-Change Increase"; break;
                case 4:  TempEvent = "Temperature Report-on-Change Decrease"; break;
                default: TempEvent = "Undefined"; break;
            }
            // current temperature reading
            Temperature = Convert(bytes[3], 0);
            // relative temp measurement for use with an alternative calibration table
            TempRelative = Convert(bytes[4], 0);

            decode = {data: {
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "TEMPERATURE",
              Temperature: {
                Event: TempEvent,
                Temperature: Temperature,
                Relative: TempRelative,
            }}};
            break;

        // ====================  TILT EVENT  =======================
        case TILT_EVENT:
            EventType = bytes[2];
            switch (EventType) {
                case 0:  TiltEvent = "Transitioned to Vertical"; break;
                case 1:  TiltEvent = "Transitioned to Horizontal"; break;
                case 2:  TiltEvent = "Report-on-Change Toward Vertical"; break;
                case 3:  TiltEvent = "Report-on-Change Toward Horizontal"; break;
                default: TiltEvent = "Undefined"; break;
            }
            TiltAngle = bytes[3];

            decode = {data: {
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "TILT",
              Tilt: {
                Event: TiltEvent,
                Angle: TiltAngle,
            }}};
            break;

        // =============  AIR TEMP & HUMIDITY EVENT  ===============
        case ATH_EVENT:
            EventType = bytes[2];
            switch (EventType) {
                case 0:  ATHEvent = "Periodic Report"; break;
                case 1:  ATHEvent = "Temperature has Risen Above Upper Threshold"; break;
                case 2:  ATHEvent = "Temperature has Fallen Below Lower Threshold"; break;
                case 3:  ATHEvent = "Temperature Report-on-Change Increase"; break;
                case 4:  ATHEvent = "Temperature Report-on-Change Decrease"; break;
                case 5:  ATHEvent = "Humidity has Risen Above Upper Threshold"; break;
                case 6:  ATHEvent = "Humidity has Fallen Below Lower Threshold"; break;
                case 7:  ATHEvent = "Humidity Report-on-Change Increase"; break;
                case 8:  ATHEvent = "Humidity Report-on-Change Decrease"; break;
                default: ATHEvent = "Undefined"; break;
            }

            // integer and fractional values between two bytes
            Temperature = Convert((bytes[3]) + ((bytes[4] >> 4) / 10), 1);
            // integer and fractional values between two bytes
            Humidity = +(bytes[5] + ((bytes[6]>>4) / 10)).toFixed(1);

            decode = {data: {
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "ATH",
              ATH: {
                Event: ATHEvent,
                Temperature: Temperature,
                Humidity: Humidity
            }}};
            break;

        // ============  ACCELERATION MOVEMENT EVENT  ==============
        case ABM_EVENT:
            EventType = bytes[2];
            if (EventType == 0)
                ABMEvent = "Movement Started";
            else
                ABMEvent = "Movement Stopped";

            decode = {data: {
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "ABM",
              ABM: {
                Event: ABMEvent,
            }}};
            break;

        // =============  HIGH-PRECISION TILT EVENT  ===============
        case TILT_HP_EVENT:
            EventType = bytes[2];
            switch (EventType) {
                case 0:  TiltHPEvent = "Periodic Report"; break;
                case 1:  TiltHPEvent = "Transitioned Toward 0-Degree Vertical Orientation"; break;
                case 2:  TiltHPEvent = "Transitioned Away From 0-Degree Vertical Orientation"; break;
                case 3:  TiltHPEvent = "Report-on-Change Toward 0-Degree Vertical Orientation"; break;
                case 4:  TiltHPEvent = "Report-on-Change Away From 0-Degree Vertical Orientation"; break;
                default: TiltHPEvent = "Undefined"; break;
            }
            // integer and fractional values between two bytes
            TiltHPAngle = +(bytes[3] + (bytes[4] / 10)).toFixed(1);
            Temperature = Convert(bytes[5], 0);
            decode = {data: {
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "TILT-HP",
              TiltHP: {
                Event: TiltHPEvent,
                Angle: TiltHPAngle,
                Temperature: Temperature
            }}};
            break;

        // ===============  ULTRASONIC LEVEL EVENT  ================
        case ULTRASONIC_EVENT:
            EventType = bytes[2];
            switch (EventType) {
                case 0:  UltrasonicEvent = "Periodic Report"; break;
                case 1:  UltrasonicEvent = "Distance has Risen Above Upper Threshold"; break;
                case 2:  UltrasonicEvent = "Distance has Fallen Below Lower Threshold"; break;
                case 3:  UltrasonicEvent = "Report-on-Change Increase"; break;
                case 4:  UltrasonicEvent = "Report-on-Change Decrease"; break;
                default: UltrasonicEvent = "Undefined"; break;
            }
            // distance is calculated across 16-bits
            Distance = ((bytes[3] * 256) + bytes[4]);
            // log.trace('byte3 + byte4:' + bytes[3] + ',' + bytes[4])

            decode = {data: {
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "ULTRASONIC",
              Ultrasonic: {
                Event: UltrasonicEvent,
                Distance: Distance,
            }}};
            
            break;

        // ================  4-20mA ANALOG EVENT  ==================
        case SENSOR420MA_EVENT:
            EventType = bytes[2];
            switch (EventType) {
              case 0:  A420mAEvent = "Periodic Report"; break;
              case 1:  A420mAEvent = "Analog Value has Risen Above Upper Threshold"; break;
              case 2:  A420mAEvent = "Analog Value has Fallen Below Lower Threshold"; break;
              case 3:  A420mAEvent = "Report on Change Increase"; break;
              case 4:  A420mAEvent = "Report on Change Decrease"; break;
              default: A420mAEvent = "Undefined"; break;
            }
            // calculatec across 16-bits, convert from units of 10uA to mA
            Analog420mA = ((bytes[3] * 256) + bytes[4]) / 100;

            decode = {data: {
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "4-20mA",
              A420mA: {
                Event: A420mAEvent,
                Current: Analog420mA,
            }}};
            break;

        // =================  THERMOCOUPLE EVENT  ==================
        case THERMOCOUPLE_EVENT:
            EventType = bytes[2];
            switch (EventType) {
                case 0:  ThermocoupleEvent = "Periodic Report"; break;
                case 1:  ThermocoupleEvent = "Analog Value has Risen Above Upper Threshold"; break;
                case 2:  ThermocoupleEvent = "Analog Value has Fallen Below Lower Threshold"; break;
                case 3:  ThermocoupleEvent = "Report on Change Increase"; break;
                case 4:  ThermocoupleEvent = "Report on Change Decrease"; break;
                default: ThermocoupleEvent = "Undefined"; break;
            }
            // decode is across 16-bits
            Temperature = (((bytes[3] * 256) + bytes[4]) / 16).toFixed(2);
            Faults = bytes[5];
            // decode each bit in the fault byte
            FaultColdOutsideRange = (Faults >> 7) & 0x01;
            FaultHotOutsideRange = (Faults >> 6) & 0x01;
            FaultColdAboveThresh = (Faults >> 5) & 0x01;
            FaultColdBelowThresh = (Faults >> 4) & 0x01;
            FaultTCTooHigh = (Faults >> 3) & 0x01;
            FaultTCTooLow = (Faults >> 2) & 0x01;
            FaultVoltageOutsideRange = (Faults >> 1) & 0x01;
            FaultOpenCircuit = Faults & 0x01;
            // Decode faults
            if (FaultColdOutsideRange)    FaultCOR = "True"; else FaultCOR = "False";
            if (FaultHotOutsideRange)     FaultHOR = "True"; else FaultHOR = "False";
            if (FaultColdAboveThresh)     FaultCAT = "True"; else FaultCAT = "False";
            if (FaultColdBelowThresh)     FaultCBT = "True"; else FaultCBT = "False";
            if (FaultTCTooHigh)           FaultTCH = "True"; else FaultTCH = "False";
            if (FaultTCTooLow)            FaultTCL = "True"; else FaultTCL = "False";
            if (FaultVoltageOutsideRange) FaultVOR = "True"; else FaultVOR = "False";
            if (FaultOpenCircuit)         FaultOPC = "True"; else FaultOPC = "False";

            decode = {data: {
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "Thermocouple",
              Thermocouple: {
                Event: ThermocoupleEvent,
                Temperature: Temperature,
                Fault: {
                  ColdOutsideRange: FaultCOR,
                  HotOutsideRange: FaultHOR,
                  ColdAboveThresh: FaultCAT,
                  ColdBelowThresh: FaultCBT,
                  TCTooHigh: FaultTCH,
                  TCTooLow: FaultTCL,
                  VoltageOutsideRange: FaultVOR,
                  OpenCircuit: FaultOPC
            }}}};
            break;

        // ================  VOLTMETER EVENT  ==================
        case VOLTMETER_EVENT:
            EventType = bytes[2];
            switch (EventType) {
                case 0:  VoltmeterEvent = "Periodic Report"; break;
                case 1:  VoltmeterEvent = "Voltage has Risen Above Upper Threshold"; break;
                case 2:  VoltmeterEvent = "Voltage has Fallen Below Lower Threshold"; break;
                case 3:  VoltmeterEvent = "Report on Change Increase"; break;
                case 4:  VoltmeterEvent = "Report on Change Decrease"; break;
                default: VoltmeterEvent = "Undefined";
            }
            // voltage is measured across 16-bits, convert from units of 10mV to V
            Voltage = ((bytes[3] * 256) + bytes[4]) / 100;

            decode = {data: {
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "VOLTMETER",
              Voltmeter: {
                Event: VoltmeterEvent,
                Voltage: Voltage,
            }}};
            // log.trace('VOLTMETER_EVENT:\n' + JSON.stringify(decode));
            break;

        // ================  CUSTOM SENSOR EVENT  ==================
        //case CUSTOM_SENSOR_EVENT:
        //    decoded.Message = "Event: Custom Sensor";
        //    Custom sensors are not decoded here
        //    break;


        // ================  GPS EVENT  ==================
        case GPS_EVENT:
            EventType = bytes[2];
            // decode status byte
            GPSValidFix = EventType & 0x01;
            if (GPSValidFix == 0)
                FixValid = "False";
            else
                FixValid = "True";
            // latitude and longitude calculated across 32 bits each, show 12 decimal places
            Latitude = toFixed((((bytes[3] * (2 ^ 24)) + (bytes[4] * (2 ^ 16)) + (bytes[5] * (2 ^ 8)) + bytes[6]) / (10 ^ 7)), 12);
            Longitude = toFixed((((bytes[7] * (2 ^ 24)) + (bytes[8] * (2 ^ 16)) + (bytes[9] * (2 ^ 8)) + bytes[10]) / (10 ^ 7)), 12);

            decode = {data: {
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "GPS",
              GPS: {
                FixValid: FixValid,
                Latitude: Latitude,
                Longitude: Longitude
            }}};
            break;

        // ================  HONEYWELL 5800 EVENT  ==================
        case HONEYWELL5800_EVENT:
            // honeywell sensor ID, 24-bits
            //HWSensorID = Hex((bytes[3] * (2 ^ 16)) + (bytes[4] * (2 ^ 8)) + bytes[5]);
            HWSensorID = Hex(bytes[3])+Hex(bytes[4])+Hex(bytes[5]);
            EventType = bytes[2];
            switch (EventType) {
                case 0: HWEvent = "Status code"; break;
                case 1: HWEvent = "Error Code"; break;
                case 2: HWEvent = "Sensor Data Payload"; break;
                default: HWEvent = "Undefined"; break;
            }
            // represent the honeywell sensor payload in hex
            HWPayload = Hex(bytes[6]);

            decode = {data: {
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "HONEYWELL5800",
              Honeywell: {
                DeviceID: HWSensorID,
                Event: HWEvent,
                Payload: HWPayload,
            }}};
            break;

        // ================  MAGNETOMETER EVENT  ==================
        //case MAGNETOMETER_EVENT:
            // TBD
        //    break;

        // ==================   DOWNLINK EVENT  ====================
        case DOWNLINK_ACK_EVENT:
            EventType = bytes[2];
            if (EventType == 1)
                DownlinkEvent = "Message Invalid";
            else
                DownlinkEvent = "Message Valid";

            decode = {data: {
              Protocol: ProtocolVersion,
              Counter: PacketCounter,
              Type: "DOWNLINKACK",
              DownlinkACK: {
                Event: DownlinkEvent,
            }}};
            break;

        // end of EventType Case
    }

    // add packet counter and protocol version to the end of the decode
    // decoded.Message += ", Packet Counter: " + PacketCounter;
    // decoded.Message += ", Protocol Version: " + ProtocolVersion;

// return decoded object
  return decode;
}

function Hex(decimal) {
    decimal = ('0' + decimal.toString(16).toUpperCase()).slice(-2);
    return decimal;
}

function Convert(number, mode) {
    switch (mode) {
        // for EXT-TEMP and NOP 
        case 0: if (number > 127) { result = number - 256 } else { result = number }; break
        //for ATH temp
        case 1: if (number > 127) { result = -+(number - 128).toFixed(1) } else { result = +number.toFixed(1) }; break
    }
    return result;
}

```
