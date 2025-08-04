mod jobs;
mod logging;
mod mapmanip;
mod milla;
<<<<<<< HEAD
=======
mod rustlibs_dmi;
mod rustlibs_file;
mod rustlibs_http;
mod rustlibs_json;
mod rustlibs_logging;
mod rustlibs_noisegen;
mod rustlibs_redispubsub;
mod rustlibs_toml;
<<<<<<< HEAD
>>>>>>> f52435ff064b75d6426124baab926c0dd89c0910

#[cfg(all(not(feature = "byond-515"), not(feature = "byond-516")))]
compile_error!("Please specify byond-515 or byond-516 as a feature to specify BYOND version.");

#[cfg(all(feature = "byond-515", feature = "byond-516"))]
compile_error!(
    "Please specify ONLY byond-515 or bypnd-516 as a feature to specify BYOND version, not all features."
);
=======
>>>>>>> e3b04880c842ca6b85a169dd5affd7f668c3a555
