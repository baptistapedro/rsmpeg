extern crate rsmpeg;

use std::ffi::{CStr, CString};
use std::error::Error;
use rsmpeg::avformat::AVFormatContextInput;
use std::env;

fn dump_av_info(path: &CStr) -> Result<(), Box<dyn Error>> {
    let mut input_format_context = AVFormatContextInput::open(path)?;
    input_format_context.dump(0, path)?;
    Ok(())
}

fn main() {
    let args: Vec<String> = env::args().collect();
    dump_av_info(&CString::new(&*args[1]).unwrap()).unwrap();
}
