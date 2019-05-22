package shared

// System consts
const (
	// Tables and Views
	TableCoreTrees               string = "core_trees"
	TableCoreTreLevels           string = "core_tre_levels"
	TableCoreTreUnits            string = "core_tre_units"
	TableCoreCurrencies          string = "core_currencies"
	TableCoreCryRates            string = "core_cry_rates"
	TableCoreConfigLanguages     string = "core_config_languages"
	TableCoreUsers               string = "core_users"
	TableCoreGroups              string = "core_groups"
	TableCoreGrpPermissions      string = "core_grp_permissions"
	TableCoreGroupsUsers         string = "core_groups_users"
	TableCoreSchemas             string = "core_schemas"
	TableCoreSchFollowers        string = "core_sch_followers"
	TableCoreSchemasModels       string = "core_schemas_models"
	TableCoreLookups             string = "core_lookups"
	TableCoreLkpOptions          string = "core_lkp_options"
	TableCoreSchFields           string = "core_sch_fields"
	TableCoreSchFldValidations   string = "core_sch_fld_validations"
	TableCoreWidgets             string = "core_widgets"
	TableCoreSchViews            string = "core_sch_views"
	TableCoreSchPages            string = "core_sch_pages"
	TableCoreViewsPages          string = "core_views_pages"
	TableCoreSchPagSections      string = "core_sch_pag_sections"
	TableCoreSchPagSecTabs       string = "core_sch_pag_sec_tabs"
	TableCoreSchPagCntStructures string = "core_sch_pag_cnt_structures"
	TableCoreTranslations        string = "core_translations"
	TableCoreJobs                string = "core_jobs"
	TableCoreJobsFollowers       string = "core_jobs_followers"
	TableCoreJobTasks            string = "core_job_tasks"
	TableCoreJobInstances        string = "core_job_instances"
	TableCoreJobTaskInstances    string = "core_job_task_instances"
	TableCoreServices            string = "core_services"
	TableCoreSystemParams        string = "core_system_params"
	ViewCoreJobFollowers         string = "core_v_job_followers"
	ViewCoreJobInstances         string = "core_v_job_instance"
	ViewCoreJobTaskInstances     string = "core_v_job_task_instance"
	ViewCoreUsersAndGroups       string = "core_v_users_and_groups"
	ViewCoreSchModules           string = "core_v_sch_modules"
	ViewCoreUserGroups           string = "core_v_user_groups"
	ViewCoreGroupUsers           string = "core_v_group_users"

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
	ErrorLoadingInstances string = "007-ErrorLoadingInstances"

	// Service types
	ServiceTypeExternal  string = "external"
	ServiceTypeModule    string = "module"
	ServiceTypeAuxiliary string = "auxiliary"

	// System parameters
	SysParamAPIHost          string = "api_host"
	SysParamAPILoginURL      string = "api_login_url"
	SysParamAPILoginEmail    string = "api_login_email"
	SysParamAPILoginPassword string = "api_login_password"
)
