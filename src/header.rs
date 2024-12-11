#[repr(C)]
pub struct FwContainerHeader {
    pub tag: u8,
    pub version: u8,
    pub length: u16,
    pub flags: u32,
    pub sw_version: u16,
    pub fuse_version: u8,
    pub number_of_fw: u8,
    pub device_config_block_offset: u16,
    pub signature_block_offset: u16,
}

type LinkerScriptSymbol = unsafe extern "C" fn();

#[repr(C)]
pub struct FwInfoTable {
    pub offset: LinkerScriptSymbol,
    pub size: LinkerScriptSymbol,
    pub flags: u32,
    pub _reserved1: u32,
    pub load_addr: LinkerScriptSymbol,
    pub _reserved2: u32,
    pub entry_point: LinkerScriptSymbol,
    pub _reserved3: u32,
    pub hash: [u8; 64],
    pub _reserved4: [u8; 32],
}

pub mod linker_script_symbols {
    extern "C" {
        pub fn _start();
        pub fn __fw_size__();
        pub fn __fw_offset__();
    }
}

#[macro_export]
macro_rules! hpm_firmware_headers {
    ($sw_version:expr) => {
        mod __hpm_firmware_header {
            use $crate::header::{linker_script_symbols::*, FwContainerHeader, FwInfoTable};
            #[link_section = ".boot_header"]
            #[allow(dead_code)]
            #[no_mangle]
            pub static FW_CONTAINER_HEADER: FwContainerHeader = FwContainerHeader {
                tag: 0xBF,
                version: 0x10,
                length: (core::mem::size_of::<FwContainerHeader>()
                    + core::mem::size_of::<FwInfoTable>()) as u16,
                flags: 0x00,
                sw_version: $sw_version,
                fuse_version: 0x00,
                number_of_fw: 0x01,
                device_config_block_offset: 0x00,
                signature_block_offset: 0x00,
            };

            #[link_section = ".fw_info_table"]
            #[allow(dead_code)]
            #[no_mangle]
            pub static FW_INFO_TABLE: FwInfoTable = FwInfoTable {
                offset: __fw_offset__,
                size: __fw_size__,
                flags: 0x00,
                _reserved1: 0x00,
                load_addr: _start,
                _reserved2: 0x00,
                entry_point: _start,
                _reserved3: 0x00,
                hash: [0; 64],
                _reserved4: [0; 32],
            };
        }
    };
}

#[macro_export]
macro_rules! hpm_flash_config_header {
    () => {
        mod __hpm_flash_header {
            #[link_section = ".flash_config"]
            #[allow(dead_code)]
            #[no_mangle]
            pub static FLASH_CONFIG: [u32; 4] = [0xfcf90002, 0x00000006, 0x1000, 0x0];
        }
    };
}
