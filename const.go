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
	ViewCoreJobFollowers         string = "core_v_job_followers"
	ViewCoreUsersAndGroups       string = "core_v_users_and_groups"
	ViewCoreUserGroups           string = "core_v_user_groups"
	ViewCoreGroupUsers           string = "core_v_group_users"

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

	// System job codes
	JobSystemCreateSchema string = "job_system_create_schema"

	// Response errors
	ErrorParsingRequest  string = "001-ErrorParsingRequest"
	ErrorInsertingRecord string = "002-ErrorInsertingRecord"
	ErrorReturningData   string = "003-ErrorReturningData"
	ErrorDeletingData    string = "004-ErrorDeletingData"
	ErrorLoadingData     string = "005-ErrorLoadingData"
	ErrorLogin           string = "006-ErrorLoginUser"
	ErrorJobExecution    string = "007-ErrorJobExecution"
)
