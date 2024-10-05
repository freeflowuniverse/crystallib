module herocontainers

struct BuilderInfo {
	type_                    string            @[json: 'Type']
	from_image               string            @[json: 'FromImage']
	from_image_id            string            @[json: 'FromImageID']
	from_image_digest        string            @[json: 'FromImageDigest']
	group_add                []string          @[json: 'GroupAdd']
	config                   string            @[json: 'Config']
	manifest                 string            @[json: 'Manifest']
	container                string            @[json: 'Container']
	container_id             string            @[json: 'ContainerID']
	mount_point              string            @[json: 'MountPoint']
	process_label            string            @[json: 'ProcessLabel']
	mount_label              string            @[json: 'MountLabel']
	image_annotations        ImageAnnotations  @[json: 'ImageAnnotations']
	image_created_by         string            @[json: 'ImageCreatedBy']
	oci_v1                   OCIv1             @[json: 'OCIv1']
	docker                   Docker            @[json: 'Docker']
	default_mounts_file_path string            @[json: 'DefaultMountsFilePath']
	isolation                string            @[json: 'Isolation']
	namespace_options        []NamespaceOption @[json: 'NamespaceOptions']
	capabilities             []string          @[json: 'Capabilities']
	configure_network        string            @[json: 'ConfigureNetwork']
	// cni_plugin_path        string            @[json: 'CNIPluginPath']
	// cni_config_dir         string            @[json: 'CNIConfigDir']
	// id_mapping_options     IDMappingOptions  @[json: 'IDMappingOptions']
	history []string @[json: 'History']
	devices []string @[json: 'Devices']
}

struct ImageAnnotations {
	org_opencontainers_image_base_digest string @[json: 'org.opencontainers.image.base.digest']
	org_opencontainers_image_base_name   string @[json: 'org.opencontainers.image.base.name']
}

struct OCIv1 {
	created      string            @[json: 'created']
	architecture string            @[json: 'architecture']
	os           string            @[json: 'os']
	config       map[string]string @[json: 'config']
	rootfs       Rootfs            @[json: 'rootfs']
}

struct Rootfs {
	type_    string   @[json: 'type']
	diff_ids []string @[json: 'diff_ids']
}

struct Docker {
	created          string          @[json: 'created']
	container_config ContainerConfig @[json: 'container_config']
	config           DockerConfig    @[json: 'config']
	architecture     string          @[json: 'architecture']
	os               string          @[json: 'os']
}

struct ContainerConfig {
	hostname      string            @[json: 'Hostname']
	domainname    string            @[json: 'Domainname']
	user          string            @[json: 'User']
	attach_stdin  bool              @[json: 'AttachStdin']
	attach_stdout bool              @[json: 'AttachStdout']
	attach_stderr bool              @[json: 'AttachStderr']
	tty           bool              @[json: 'Tty']
	open_stdin    bool              @[json: 'OpenStdin']
	stdin_once    bool              @[json: 'StdinOnce']
	env           []string          @[json: 'Env']
	cmd           []string          @[json: 'Cmd']
	image         string            @[json: 'Image']
	volumes       map[string]string @[json: 'Volumes']
	working_dir   string            @[json: 'WorkingDir']
	entrypoint    []string          @[json: 'Entrypoint']
	on_build      []string          @[json: 'OnBuild']
	labels        map[string]string @[json: 'Labels']
}

struct DockerConfig {
	// Assuming identical structure to ContainerConfig
	// Define fields with @json: mapping if different
}

struct NamespaceOption {
	name string @[json: 'Name']
	host bool   @[json: 'Host']
	path string @[json: 'Path']
}

// struct IDMappingOptions {
//     host_uid_mapping         bool     @[json: 'HostUIDMapping']
//     host_gid_mapping         bool     @[json: 'HostGIDMapping']
//     // uid_map                  []UIDMap @[json: 'UIDMap']
//     // gid_map                  []GIDMap @[json: 'GIDMap']
//     auto_user_ns             bool     @[json: 'AutoUserNs']
//     auto_user_ns_opts        AutoUserNsOpts @[json: 'AutoUserNsOpts']
// }

// struct UIDMap {
//     // Define the structure with @json: mappings
// }

// struct GIDMap {
//     // Define the structure with @json: mappings
// }

// struct AutoUserNsOpts {
//     size                     int      @[json: 'Size']
//     initial_size             int      @[json: 'InitialSize']
//     passwd_file              string   @[json: 'PasswdFile']
//     group_file               string   @[json: 'GroupFile']
//     additional_uid_mappings  []UIDMap @[json: 'AdditionalUIDMappings']
//     additional_gid_mappings  []GIDMap @[json: 'AdditionalGIDMappings']
// }
