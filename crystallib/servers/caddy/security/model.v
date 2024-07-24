module security

pub struct PrivateLink {
pub mut:
    link           string
    title          string
    style          string
    open_new_window bool
    target         string
    target_enabled bool
    icon_name      string
    icon_enabled   bool
}

pub struct Realm {
pub mut:
    name  string
    label string
}

pub struct UIConfig {
pub mut:
    theme                   string
    templates               map[string]string
    allow_role_selection    bool
    title                   string
    logo_url                string
    logo_description        string
    private_links           []PrivateLink
    auto_redirect_url       string
    realms                  []Realm
    password_recovery_enabled bool
    custom_css_path         string
    custom_js_path          string
}

pub struct UserRegistrationConfig {
pub mut:
    disabled              bool
    title                 string
    code                  string
    dropbox               string
    require_accept_terms  bool
    require_domain_mx     bool
    terms_conditions_link string
    privacy_policy_link   string
    email_provider        string
    admin_emails          []string
}

pub struct UserTransformerConfig {
pub mut:
    matchers []string
    actions  []string
}

pub struct DomainConfig {
pub mut:
    seq       int
    domain    string
    path      string
    lifetime  int
    insecure  bool
    same_site string
}

pub struct CookieConfig {
pub mut:
    domains   map[string]DomainConfig
    path      string
    lifetime  int
    insecure  bool
    same_site string
}

pub struct AccessListConfig {
pub mut:
    comment    string
    conditions []string
    action     string
}

pub struct TokenValidatorOptions {
pub mut:
    validate_source_address       bool
    validate_bearer_header        bool
    validate_method_path          bool
    validate_access_list_path_claim bool
}

pub struct CryptoKeyConfig {
pub mut:
    seq              int
    id               string
    usage            string
    token_name       string
    source           string
    algorithm        string
    env_var_name     string
    env_var_type     string
    env_var_value    string
    file_path        string
    dir_path         string
    token_lifetime   int
    token_secret     string
    token_sign_method string
    token_eval_expr  []string
}

pub struct TokenGrantorOptions {
pub mut:
    enable_source_address bool
}

pub struct APIConfig {
pub mut:
    enabled bool
}

pub struct AuthenticationPortal {
pub mut:
    name                   string
    ui                     UIConfig
    user_registration_config UserRegistrationConfig
    user_transformer_configs []UserTransformerConfig
    cookie_config          CookieConfig
    identity_stores        []string
    identity_providers     []string
    access_list_configs    []AccessListConfig
    token_validator_options TokenValidatorOptions
    crypto_key_configs     []CryptoKeyConfig
    crypto_key_store_config map[string]string
    token_grantor_options  TokenGrantorOptions
    api                    APIConfig
}

pub struct BypassConfig {
pub mut:
    match_type string
    uri        string
}

pub struct HeaderInjectionConfig {
pub mut:
    header string
    field  string
}

pub struct AuthorizationPolicy {
pub mut:
    name                      string
    auth_url_path             string
    disable_auth_redirect     bool
    disable_auth_redirect_query bool
    auth_redirect_query_param string
    auth_redirect_status_code int
    redirect_with_javascript  bool
    bypass_configs            []BypassConfig
    header_injection_configs  []HeaderInjectionConfig
    access_list_rules         []AccessListConfig
    crypto_key_configs        []CryptoKeyConfig
    crypto_key_store_config   map[string]string
    auth_proxy_config         map[string]map[string]bool
    allowed_token_sources     []string
    strip_token_enabled       bool
    forbidden_url             string
    user_identity_field       string
    validate_bearer_header    bool
    validate_method_path      bool
    validate_access_list_path_claim bool
    validate_source_address   bool
    pass_claims_with_headers  bool
    login_hint_validators     []string
}

pub struct EmailProvider {
pub mut:
    name               string
    address            string
    protocol           string
    credentials        string
    sender_email       string
    sender_name        string
    templates          map[string]string
    passwordless       bool
    blind_carbon_copy  []string
}

pub struct FileProvider {
pub mut:
    name      string
    root_dir  string
    templates map[string]string
}

pub struct MessagingConfig {
pub mut:
    email_providers []EmailProvider
    file_providers  []FileProvider
}

pub struct IdentityStore {
pub mut:
    name   string
    kind   string
    params map[string]string
}

pub struct IdentityProvider {
pub mut:
    name   string
    kind   string
    params map[string]string
}

pub struct Security {
pub mut:
    config Config
}

pub struct Config {
pub mut:
    credentials           map[string][]GenericCredential @[skip; omitempty]
    authentication_portals []AuthenticationPortal
    authorization_policies []AuthorizationPolicy
    messaging              MessagingConfig
    identity_stores        []IdentityStore
    identity_providers     []IdentityProvider
}

pub struct GenericCredential {
pub mut:
    name     string
    username string
    password string
    domain   string
}