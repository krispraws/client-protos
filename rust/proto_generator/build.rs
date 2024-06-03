use std::path::PathBuf;
#[allow(clippy::unwrap_used)]
fn main() {
    let out_dir = PathBuf::from("../momento-protos/src");
    let proto_dir = "../proto";

    eprintln!("Hi brave developer! If you are changing protos and momento-protos fails to build, please retry 1 time.");
    eprintln!("Cargo currently does not have a nice way for us to express a dependency order between these 2");
    eprintln!("workspace projects - because this project is _specifically_ supposed to not be a Cargo dependency.");
    eprintln!("We did this so downstream users don't need to have protoc when compiling momento-protos!");

    eprintln!("If you are finding that your builds work locally, but not in CI, then you need to manual cleanup some artifacts");
    eprintln!("Clear out the `momento-protos/src` of all protos besides lib.rs, then run `cargo clean` and `cargo build`.");

    tonic_build::configure()
        .build_client(true)
        .build_server(true)
        .out_dir(out_dir)
        .compile(
            &[
                format!("{proto_dir}/permissionmessages.proto"),
                format!("{proto_dir}/auth.proto"),
                format!("{proto_dir}/token.proto"),
                format!("{proto_dir}/cacheclient.proto"),
                format!("{proto_dir}/cachepubsub.proto"),
                format!("{proto_dir}/controlclient.proto"),
                format!("{proto_dir}/vectorindex.proto"),
                format!("{proto_dir}/store.proto"),
            ],
            &[proto_dir],
        )
        .unwrap_or_else(|e| panic!("Failed to compile protos {:?}", e));

    println!("cargo:rerun-if-changed=../proto");
}
