package constants

// System consts
const (
	// Prefix Table
	InstancesTablePrefix string = "cst_"

	// database config
	DatabaseMaxLength int = 45

	// Tables
	TableCoreModules                       string = "core_modules"
	TableCoreBPM                           string = "core_bpm"
	TableCoreBPMSteps                      string = "core_bpm_steps"
	TableCoreBPMInstances                  string = "core_bpm_instances"
	TableCoreBPMStepInstances              string = "core_bpm_step_instances"
	TableCoreContents                      string = "core_contents"
	TableCoreDatasets                      string = "core_datasets"
	TableCoreTrees                         string = "core_trees"
	TableCoreTreeLevels                    string = "core_tree_levels"
	TableCoreTreeUnits                     string = "core_tree_units"
	TableCoreCurrencies                    string = "core_currencies"
	TableCoreCurrencyRates                 string = "core_cry_rates"
	TableCoreConfigLanguages               string = "core_config_languages"
	TableCoreUsers                         string = "core_users"
	TableCoreInstancePermissions           string = "core_instance_premissions"
	TableCoreUserNotifications             string = "core_user_notifications"
	TableCoreUserNotificationEmails        string = "core_user_notification_emails"
	TableCoreGroups                        string = "core_groups"
	TableCoreSchemas                       string = "core_schemas"
	TableCoreSchemaFollowers               string = "core_sch_followers"
	TableCoreSchemasModels                 string = "core_schemas_models"
	TableCoreLookups                       string = "core_lookups"
	TableCoreSchemaFields                  string = "core_schema_fields"
	TableCoreWidgets                       string = "core_widgets"
	TableCoreSchemaViews                   string = "core_sch_views"
	TableCoreSchemaPages                   string = "core_sch_pages"
	TableCoreViewsPages                    string = "core_views_pages"
	TableCoreSchemaPagSections             string = "core_sch_pag_sections"
	TableCoreSchemaPageSectionTabs         string = "core_sch_pag_sec_tabs"
	TableCoreSchemaPageContainerStructures string = "core_sch_pag_cnt_structures"
	TableCoreTranslations                  string = "core_translations"
	TableCoreJobs                          string = "core_jobs"
	TableCoreJobsFollowers                 string = "core_jobs_followers"
	TableCoreJobTasks                      string = "core_job_tasks"
	TableCoreJobInstances                  string = "core_job_instances"
	TableCoreJobTaskInstances              string = "core_job_task_instances"
	TableCoreServices                      string = "core_services"
	TableCoreSystemParams                  string = "core_system_params"

	// Views
	ViewCoreJobFollowers             string = "core_v_job_followers"
	ViewCoreJobInstances             string = "core_v_job_instance"
	ViewCoreJobTaskInstances         string = "core_v_job_task_instance"
	ViewCoreUsersAndGroups           string = "core_v_users_and_groups"
	ViewCoreSchemaModules            string = "core_v_sch_modules"
	ViewCoreUserGroups               string = "core_v_user_groups"
	ViewCoreGroupUsers               string = "core_v_group_users"
	ViewCoreUserStructurePermissions string = "core_v_user_structure_permissions"
	ViewCoreStructurePermissions     string = "core_v_structure_permissions"
	ViewCoreUserAllPermissions       string = "core_v_user_all_permissions"
	ViewCoreUserInstancePermissions  string = "core_v_user_instance_permissions"

	// Custom schemas
	TableCustomResources string = "cst_resources"

	// Schema status
	SchemaStatusProcessing string = "processing"
	SchemaStatusCompleted  string = "completed"
	SchemaStatusDeleting   string = "deleting"

	// Job status
	JobStatusCreating    string = "creating"
	JobStatusCreated     string = "created"
	JobStatusInQueue     string = "queued"
	JobStatusProcessing  string = "processing"
	JobStatusCompleted   string = "completed"
	JobStatusWarnings    string = "warnings"
	JobStatusFail        string = "fail"
	JobStatusRollbacking string = "rollbacking"
	JobStatusRetrying    string = "retrying"

	// Job execution action
	ExecuteQuery     string = "exec_query"
	ExecuteAPIGet    string = "api_get"
	ExecuteAPIPost   string = "api_post"
	ExecuteAPIDelete string = "api_delete"
	ExecuteAPIUpdate string = "api_patch"

	// Job action on faill
	OnFailContinue          string = "continue"
	OnFailRetryAndContinue  string = "retry_and_continue"
	OnFailCancel            string = "cancel"
	OnFailRetryAndCancel    string = "retry_and_cancel"
	OnFailRollback          string = "rollback"
	OnFailRollbackAndCancel string = "rollback_and_cancel"

	// System job codes
	JobSystemCreateSchema string = "job_system_create_schema"
	JobSystemDeleteSchema string = "job_system_delete_schema"

	// Response errors
	ErrorParsingRequest   string = "001-ErrorParsingRequest"
	ErrorInsertingRecord  string = "002-ErrorInsertingRecord"
	ErrorReturningData    string = "003-ErrorReturningData"
	ErrorDeletingData     string = "004-ErrorDeletingData"
	ErrorLoadingData      string = "005-ErrorLoadingData"
	ErrorLogin            string = "006-ErrorLoginUser"
	ErrorJobExecution     string = "007-ErrorJobExecution"
	ErrorLoadingInstances string = "008-ErrorLoadingInstances"

	// Service types
	ServiceTypeModule    string = "mdl"
	ServiceTypeAuxiliary string = "aux"
	ServiceTypeAPI       string = "api"

	// System parameters
	SysParamAPIHost             string = "api_host"
	SysParamAPILoginURL         string = "api_login_url"
	SysParamAPILoginEmail       string = "api_login_email"
	SysParamAPILoginPassword    string = "api_login_password"
	SysParamAPIUsername         string = "api_username"
	SysParamDefaultLanguageCode string = "default_language_code"

	// Notifications email delivery
	NotificationsEmailAlways   string = "always"
	NotificationsEmailNever    string = "never"
	NotificationsEmailRequired string = "required"

	// Security structures types
	SecurityStructureField   string = "field"
	SecurityStructureWidget  string = "widget"
	SecurityStructureSection string = "section"

	// Fields basic types
	FieldText       string = "text"
	FieldNumber     string = "number"
	FieldDate       string = "date"
	FieldLookup     string = "lookup"
	FieldAttachment string = "attachment"

	// Security permission scope
	SecurityPermissionScopeGroup     string = "group"
	SecurityPermissionScopeGroupUnit string = "group_unit"
	SecurityPermissionScopeUnit      string = "unit"

	// Dataset types
	DatasetDynamic string = "dynamic"
	DatasetStatic  string = "static"
	DatasetSchema  string = "schema"

	// Fields Lookup types
	FieldLookupStatic   string = "static"
	FieldLookupDynamic  string = "dynamic"
	FieldLookupTree     string = "tree"
	FieldLookupSecurity string = "security"

	// Fields number display
	FieldNumberDisplayMoney string = "money"

	// Data type
	SQLDataTypeText   string = "text"
	SQLDataTypeDate   string = "date"
	SQLDataTypeNumber string = "number"
	SQLDataTypeBool   string = "bool"

	// Group types
	GroupTypeGlobal string = "global"
	GroupTypeTree   string = "tree"

	// Time in seconds
	Year  int64 = 12 * Month
	Month int64 = 30 * Day
	Week  int64 = 604800
	Day   int64 = 86400
	Hour  int64 = 3600

	// Module features modes
	ModelFeatureModeMasterSchema    string = "master_schema"
	ModelFeatureModeSchemaSubObject string = "schema_subobject"
	ModelFeatureModeSchemaField     string = "schema_field"
	ModelFeatureModeField           string = "model_field"
)
