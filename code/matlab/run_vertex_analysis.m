% Set things up
fname_design = fullfile('../../data/derived/design_matrices/design_matrix_readtime+screentime+adhd.txt');
dirname_out = fullfile('../../data/derived/fema_results');

abcd_sync_path = fullfile('../../data/abcd-sync');

dataRelease = '3.0';
atlasVersion = 'ABCD1_cor10';
dirname_tabulated = fullfile(abcd_sync_path,'3.0','tabulated/released');
fname_pihat = fullfile(abcd_sync_path, '4.0','genomics','ABCD_rel4.0_grm.mat');

[root,filename]=fileparts(fname_design);
dirname_out=strcat(dirname_out,'/',filename);

% Optional inputs for `FEMA_wrapper.m` depending on analysis
contrasts=[]; % Contrasts relate to columns in design matrix e.g. [1 -1] will take the difference between cols 1 and 2 in your design matrix (X).  This needs to be padded with zeros at the beginning but not the end.
ranknorm = 1; % Rank normalizes dependent variables (Y) (default = 0)
nperms = 0; % Number of permutations - if wanting to use resampling methods nperms>0
RandomEffects = {'F','S','E'}; % Random effects to include: family, subject, error
mediation = 0; % If wanting to use outputs for a mediation analysis set mediation=1 - ensures same resampling scheme used for each model in fname_design
PermType = 'wildbootstrap'; %Default resampling method is null wild-bootstrap - to run mediation analysis need to use non-null wild-bootstrap ('wildboostrap-nn')
tfce = 0; % If wanting to run threshold free cluster enhancement (TFCE) set tfce=1 (default = 0)
colsinterest = [1]; % Only used if nperms>0. Indicates which IVs (columns of X) the permuted null distribution and TFCE statistics will be saved for (default 1, i.e. column 1)

datatype='vertex'; % imaging modality selected
modality='smri'; % concatenated imaging data stored in directories based on modality (smri, dmri, tfmri, roi)

% Uses path structure in abcd-sync to automatically find data
dirname_imaging = fullfile(abcd_sync_path, dataRelease, 'imaging_concat/vertexwise/', modality); % filepath to imaging data

switch dataRelease
    case '3.0'
          fstem_imaging = 'area-sm16';
          % fstem_imaging = 'thickness-sm256'; % name of imaging phenotype
          %fstem_imaging = 'sulc-sm256';
    case '4.0'
          fstem_imaging = 'thickness_ic5_sm256'; % name of imaging phenotype - data already saved as ico=5
          %a few of the many other choices in 4.0, including now RSI: 
          %   'thickness_ic5_sm1000', 'area_ic5_sm1000',
          %   'N0-gm_ic5_sm256','N0-gwc_ic5_sm256','N0-wm_ic5_sm256',...
          %   'ND-gm_ic5_sm256','ND-gwc_ic5_sm256','ND-wm_ic5_sm256'
end

ico = 4; % icosahedral number

% Once all filepaths and inputs have been specified FEMA_wrapper.m can be run in one line

% RUN FEMA
[fpaths_out beta_hat beta_se zmat logpmat sig2tvec sig2mat beta_hat_perm beta_se_perm zmat_perm sig2tvec_perm sig2mat_perm inputs mask tfce_perm analysis_params] = FEMA_wrapper(...
    fstem_imaging, fname_design, dirname_out, dirname_tabulated, dirname_imaging,...
    datatype, 'ico', ico, 'ranknorm', ranknorm, 'contrasts', contrasts,...
    'RandomEffects', RandomEffects, 'pihat_file', fname_pihat, 'nperms', nperms,...
    'mediation',mediation,'PermType',PermType,'tfce',tfce,...
    'colsinterest',colsinterest);

