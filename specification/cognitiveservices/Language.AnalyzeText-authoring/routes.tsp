import "@azure-tools/typespec-azure-core";
import "@typespec/rest";
import "./models.tsp";
import "@typespec/http";
import "@typespec/versioning";
import "@azure-tools/typespec-client-generator-core";

using TypeSpec.Rest;
using TypeSpec.Http;
using Azure.Core;
using Azure.Core.Traits;
using Azure.ClientGenerator.Core;
using TypeSpec.Versioning;

namespace Language.Authoring.Text;

alias ServiceTraits = NoRepeatableRequests &
  NoConditionalRequests &
  NoClientRequestId;

alias languageOperations = ResourceOperations<ServiceTraits, ErrorResponse>;

interface TextAnalysisAuthoring {
  /**
   * Lists the existing projects.
   */
  listProjects is languageOperations.ResourceList<
    ProjectMetadata,
    ListQueryParametersTrait<StandardListQueryParameters>
  >;

  /**
   * Gets the details of a project.
   */
  getProject is languageOperations.ResourceRead<ProjectMetadata>;

  #suppress "@azure-tools/typespec-azure-core/use-standard-operations" "Need to rename the body"
  @createsOrUpdatesResource(ProjectMetadata)
  @parameterVisibility
  @patch
  createProject is Foundations.ResourceOperation<
    ProjectMetadata,
    {
      @doc("This request has a JSON Merge Patch body.")
      @TypeSpec.Http.header("Content-Type")
      contentType: "application/merge-patch+json";

      /** The request body */
      @bodyRoot body: CreateProjectOptions;
    },
    Foundations.ResourceCreatedOrOkResponse<ProjectMetadata>,
    {},
    ErrorResponse
  >;

  /**
   * Deletes a project.
   */
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}")
  @delete
  @pollingOperation(TextAnalysisAuthoring.getProjectDeletionStatus)
  deleteProject is Foundations.LongRunningOperation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;
    },
    AcceptedResponse,
    {},
    ErrorResponse
  >;

  /**
   * Generates a copy project operation authorization to the current target Azure
   * resource.
   */
  #suppress "@azure-tools/typespec-azure-core/documentation-required"
  @added(Versions.v2023_04_15_preview)
  @actionSeparator("/:")
  @action("authorize-copy")
  copyProjectAuthorization is languageOperations.ResourceAction<
    ProjectMetadata,
    CopyAuthorizationOptions,
    CopyProjectOptions
  >;

  /**
   * Copies an existing project to another Azure resource.
   */
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}/:copy")
  @post
  @pollingOperation(TextAnalysisAuthoring.getCopyProjectStatus)
  @added(Versions.v2023_04_15_preview)
  copyProject is Foundations.LongRunningOperation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;

      /**
       * The copy project info.
       */
      @body
      body: CopyProjectOptions;
    },
    AcceptedResponse,
    {},
    ErrorResponse
  >;

  /**
   * Triggers a job to export a project's data.
   */
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}/:export")
  @post
  @pollingOperation(TextAnalysisAuthoring.getExportStatus)
  export is Foundations.LongRunningOperation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;

      /**
       * Specifies the method used to interpret string offsets. For additional
       * information see https://aka.ms/text-analytics-offsets.
       */
      @query("stringIndexType")
      stringIndexType: StringIndexType;

      /**
       * Kind of asset to export.
       */
      @query("assetKind")
      assetKind?: string;

      /**
       * Trained model label to export. If the trainedModelLabel is null, the default
       * behavior is to export the current working copy.
       */
      @query("trainedModelLabel")
      trainedModelLabel?: string;
    },
    AcceptedResponse,
    {},
    ErrorResponse
  >;

  /**
   * Triggers a job to import a project. If a project with the same name already
   * exists, the data of that project is replaced.
   */
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}/:import")
  @post
  @pollingOperation(TextAnalysisAuthoring.getImportStatus)
  `import` is Foundations.LongRunningOperation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;

      /**
       * The format of the project to import. The currently supported formats are json
       * and aml formats. If not provided, the default is set to json.
       */
      @added(Versions.v2023_04_15_preview)
      @header
      format?: string;

      /**
       * The project data to import.
       */
      @body
      body: ExportedProject;
    },
    AcceptedResponse,
    {},
    ErrorResponse
  >;

  /**
   * Triggers a training job for a project.
   */
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}/:train")
  @post
  @pollingOperation(TextAnalysisAuthoring.getTrainingStatus)
  train is Foundations.LongRunningOperation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;

      /**
       * The training input parameters.
       */
      @body
      body: TrainingJobOptions;
    },
    AcceptedResponse,
    {},
    ErrorResponse
  >;

  /**
   * Gets the status of an existing copy project job.
   */
  @added(Versions.v2023_04_15_preview)
  getCopyProjectStatus is languageOperations.ResourceRead<CopyProjectJobState>;

  /**
   * Lists the deployments belonging to a project.
   */
  listDeployments is languageOperations.ResourceList<
    ProjectDeployment,
    ListQueryParametersTrait<StandardListQueryParameters>
  >;

  /**
   * Gets the details of a deployment.
   */
  getDeployment is languageOperations.ResourceRead<ProjectDeployment>;

  /**
   * Creates a new deployment or replaces an existing one.
   */
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}/deployments/{deploymentName}")
  @put
  @pollingOperation(TextAnalysisAuthoring.getDeploymentStatus)
  deployProject is Foundations.LongRunningOperation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;

      /**
       * The name of the specific deployment of the project to use.
       */
      @path
      deploymentName: string;

      /**
       * The new deployment info.
       */
      @body
      body: CreateDeploymentOptions;
    },
    AcceptedResponse,
    {},
    ErrorResponse
  >;

  /**
   * Deletes a project deployment.
   */
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}/deployments/{deploymentName}")
  @delete
  @pollingOperation(TextAnalysisAuthoring.getDeploymentStatus)
  deleteDeployment is Foundations.LongRunningOperation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;

      /**
       * The name of the specific deployment of the project to use.
       */
      @path
      deploymentName: string;
    },
    AcceptedResponse,
    {},
    ErrorResponse
  >;

  /**
   * Deletes a project deployment from the specified assigned resources.
   */
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}/deployments/{deploymentName}/:delete-from-resources")
  @post
  @pollingOperation(
    TextAnalysisAuthoring.getDeploymentDeleteFromResourcesStatus
  )
  @added(Versions.v2023_04_15_preview)
  deleteDeploymentFromResources is Foundations.LongRunningOperation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;

      /**
       * The name of the specific deployment of the project to use.
       */
      @path
      deploymentName: string;

      /**
       * The options for deleting the deployment.
       */
      @body
      body: DeleteDeploymentOptions;
    },
    AcceptedResponse,
    {},
    ErrorResponse
  >;

  /**
   * Gets the status of an existing delete deployment from specific resources job.
   */
  @added(Versions.v2023_04_15_preview)
  getDeploymentDeleteFromResourcesStatus is languageOperations.ResourceRead<DeploymentDeleteFromResourcesJobState>;

  /**
   * Gets the status of an existing deployment job.
   */
  getDeploymentStatus is languageOperations.ResourceRead<DeploymentJobState>;

  /**
   * Swaps two existing deployments with each other.
   */
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}/deployments/:swap")
  @post
  @pollingOperation(TextAnalysisAuthoring.getSwapDeploymentsStatus)
  swapDeployments is Foundations.LongRunningOperation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;

      /**
       * The job object to swap two deployments.
       */
      @body
      body: SwapDeploymentsOptions;
    },
    AcceptedResponse,
    {},
    ErrorResponse
  >;

  /**
   * Gets the status of an existing swap deployment job.
   */
  getSwapDeploymentsStatus is languageOperations.ResourceRead<SwapDeploymentsJobState>;

  /**
   * Gets the status of an export job. Once job completes, returns the project
   * metadata, and assets.
   */
  getExportStatus is languageOperations.ResourceRead<ExportProjectJobState>;

  /**
   * Lists the exported models belonging to a project.
   */
  @added(Versions.v2023_04_15_preview)
  listExportedModels is languageOperations.ResourceList<
    ExportedTrainedModel,
    ListQueryParametersTrait<StandardListQueryParameters>
  >;

  /**
   * Gets the details of an exported model.
   */
  @added(Versions.v2023_04_15_preview)
  getExportedModel is languageOperations.ResourceRead<ExportedTrainedModel>;

  /**
   * Creates a new exported model or replaces an existing one.
   */
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}/exported-models/{exportedModelName}")
  @put
  @pollingOperation(TextAnalysisAuthoring.getExportedModelJobStatus)
  @added(Versions.v2023_04_15_preview)
  createOrUpdateExportedModel is Foundations.LongRunningOperation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;

      /**
       * The exported model name.
       */
      @path
      exportedModelName: string;

      /**
       * The exported model info.
       */
      @body
      body: ExportedModelOptions;
    },
    AcceptedResponse,
    {},
    ErrorResponse
  >;

  /**
   * Deletes an existing exported model.
   */
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}/exported-models/{exportedModelName}")
  @delete
  @pollingOperation(TextAnalysisAuthoring.getExportedModelJobStatus)
  @added(Versions.v2023_04_15_preview)
  deleteExportedModel is Foundations.LongRunningOperation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;

      /**
       * The exported model name.
       */
      @path
      exportedModelName: string;
    },
    AcceptedResponse,
    {},
    ErrorResponse
  >;

  /**
   * Gets the status for an existing job to create or update an exported model.
   */
  @added(Versions.v2023_04_15_preview)
  getExportedModelJobStatus is languageOperations.ResourceRead<ExportedModelJobState>;

  /**
   * Gets the details and URL needed to download the exported model.
   */
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}/exported-models/{exportedModelName}/manifest")
  @get
  @added(Versions.v2023_04_15_preview)
  getExportedModelManifest is Azure.Core.Foundations.Operation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;

      /**
       * The exported model name.
       */
      @path
      exportedModelName: string;
    },
    ExportedModelManifest,
    {},
    ErrorResponse
  >;

  /**
   * Gets the status for an import.
   */
  getImportStatus is languageOperations.ResourceRead<ImportProjectJobState>;

  /**
   * Lists the trained models belonging to a project.
   */
  listTrainedModels is languageOperations.ResourceList<
    ProjectTrainedModel,
    ListQueryParametersTrait<StandardListQueryParameters>
  >;

  /**
   * Gets the details of a trained model.
   */
  getTrainedModel is languageOperations.ResourceRead<ProjectTrainedModel>;

  /**
   * Deletes an existing trained model.
   */
  deleteTrainedModel is languageOperations.ResourceDelete<ProjectTrainedModel>;

  /**
   * Triggers evaluation operation on a trained model.
   */
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}/models/{trainedModelLabel}/:evaluate")
  @post
  @pollingOperation(TextAnalysisAuthoring.getEvaluationStatus)
  @added(Versions.v2023_04_15_preview)
  evaluateModel is Foundations.LongRunningOperation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;

      /**
       * The trained model label.
       */
      @path
      trainedModelLabel: string;

      /**
       * The training input parameters.
       */
      @body
      body: EvaluationOptions;
    },
    AcceptedResponse,
    {},
    ErrorResponse
  >;

  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}/models/{trainedModelLabel}/:load-snapshot")
  @post
  @pollingOperation(TextAnalysisAuthoring.getLoadSnapshotStatus)
  loadSnapshot is Foundations.LongRunningOperation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;

      /**
       * The trained model label.
       */
      @path
      trainedModelLabel: string;
    },
    AcceptedResponse,
    {},
    ErrorResponse
  >;

  /**
   * Gets the status for an evaluation job.
   */
  @added(Versions.v2023_04_15_preview)
  getEvaluationStatus is languageOperations.ResourceRead<EvaluationJobState>;

  /**
   * Gets the detailed results of the evaluation for a trained model. This includes
   * the raw inference results for the data included in the evaluation process.
   */
  getModelEvaluationResults is languageOperations.ResourceList<
    DocumentEvaluationResult,
    ListQueryParametersTrait<StandardListQueryParameters &
      StringIndexTypeQueryParameter>
  >;

  /**
   * Gets the evaluation summary of a trained model. The summary includes high level
   * performance measurements of the model e.g., F1, Precision, Recall, etc.
   */
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}/models/{trainedModelLabel}/evaluation/summary-result")
  @get
  getModelEvaluationSummary is Foundations.Operation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;

      /**
       * The trained model label.
       */
      @path
      trainedModelLabel: string;
    },
    EvaluationSummary,
    {},
    ErrorResponse
  >;

  /**
   * Gets the status for loading a snapshot.
   */
  getLoadSnapshotStatus is languageOperations.ResourceRead<LoadSnapshotJobState>;

  /**
   * Lists the deployments resources assigned to the project.
   */
  @added(Versions.v2023_04_15_preview)
  listDeploymentResources is languageOperations.ResourceList<
    AssignedDeploymentResource,
    ListQueryParametersTrait<StandardListQueryParameters>
  >;

  /**
   * Assign new Azure resources to a project to allow deploying new deployments to
   * them. This API is available only via AAD authentication and not supported via
   * subscription key authentication. For more details about AAD authentication,
   * check here:
   * https://learn.microsoft.com/en-us/azure/cognitive-services/authentication?tabs=powershell#authenticate-with-azure-active-directory
   */
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}/resources/:assign")
  @post
  @pollingOperation(TextAnalysisAuthoring.getAssignDeploymentResourcesStatus)
  @added(Versions.v2023_04_15_preview)
  assignDeploymentResources is Foundations.LongRunningOperation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;

      /**
       * The new project resources info.
       */
      @body
      body: AssignDeploymentResourcesOptions;
    },
    AcceptedResponse,
    {},
    ErrorResponse
  >;

  /**
   * Unassign resources from a project. This disallows deploying new deployments to
   * these resources, and deletes existing deployments assigned to them.
   */
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}/resources/:unassign")
  @post
  @pollingOperation(TextAnalysisAuthoring.getUnassignDeploymentResourcesStatus)
  @added(Versions.v2023_04_15_preview)
  unassignDeploymentResources is Foundations.LongRunningOperation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;

      /**
       * The info for the deployment resources to be deleted.
       */
      @body
      body: UnassignDeploymentResourcesOptions;
    },
    AcceptedResponse,
    {},
    ErrorResponse
  >;

  /**
   * Gets the status of an existing assign deployment resources job.
   */
  @added(Versions.v2023_04_15_preview)
  getAssignDeploymentResourcesStatus is languageOperations.ResourceRead<AssignDeploymentResourcesJobState>;

  /**
   * Gets the status of an existing unassign deployment resources job.
   */
  @added(Versions.v2023_04_15_preview)
  getUnassignDeploymentResourcesStatus is languageOperations.ResourceRead<UnassignDeploymentResourcesJobState>;

  /**
   * Lists the non-expired training jobs created for a project.
   */
  listTrainingJobs is languageOperations.ResourceList<
    TrainingJobState,
    ListQueryParametersTrait<StandardListQueryParameters>
  >;

  /**
   * Gets the status for a training job.
   */
  getTrainingStatus is languageOperations.ResourceRead<TrainingJobState>;

  /**
   * Triggers a cancellation for a running training job.
   */
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @route("/authoring/analyze-text/projects/{projectName}/train/jobs/{jobId}/:cancel")
  @post
  @pollingOperation(TextAnalysisAuthoring.getTrainingStatus)
  cancelTrainingJob is Foundations.LongRunningOperation<
    {
      /**
       * The name of the project to use.
       */
      @path
      projectName: string;

      /**
       * The job ID.
       */
      @path
      jobId: string;
    },
    AcceptedResponse,
    {},
    ErrorResponse
  >;

  /**
   * Gets the status for a project deletion job.
   */
  getProjectDeletionStatus is languageOperations.ResourceRead<ProjectDeletionJobState>;

  /**
   * Lists the deployments to which an Azure resource is assigned. This doesn't
   * return deployments belonging to projects owned by this resource. It only
   * returns deployments belonging to projects owned by other resources.
   */
  @added(Versions.v2023_04_15_preview)
  listAssignedResourceDeployments is languageOperations.ResourceList<
    AssignedProjectDeploymentsMetadata,
    ListQueryParametersTrait<StandardListQueryParameters>
  >;

  /**
   * Lists the supported languages.
   */
  getSupportedLanguages is languageOperations.ResourceList<
    SupportedLanguage,
    ListQueryParametersTrait<ProjectKindQueryParameter &
      StandardListQueryParameters>
  >;

  /**
   * Lists the supported prebuilt entities that can be used while creating composed
   * entities.
   */
  @added(Versions.v2023_04_15_preview)
  getSupportedPrebuiltEntities is languageOperations.ResourceList<
    PrebuiltEntity,
    SupportedPrebuiltEntitiesQueryParameter & StandardListQueryParameters
  >;

  /**
   * Lists the support training config version for a given project type.
   */
  listTrainingConfigVersions is languageOperations.ResourceList<
    TextAnalysisAuthoringTrainingConfigVersion,
    ListQueryParametersTrait<ProjectKindQueryParameter &
      StandardListQueryParameters>
  >;
}
