% Set things up
fname_design = fullfile('../../data/derived/design_matrices/design_matrix_readtime+screentime+adhd.txt');
dirname_out = fullfile('../../data/derived/fema_results');

% Extract the file name without the extension dynamically from fname_design
[~, fname_without_ext, ~] = fileparts(fname_design); % Extracts 'design_matrix_readtime'

% Specify the imaging phenotype
fstem_imaging = 'area-sm16';
colIDs=[2 3 4];
thresh_p = 0.001; % Threshold for p-values. Set to 0 to disable thresholding.
ico=4; % ico number

% Construct the FEMA output filename using the extracted file name
fname_results = fullfile(dirname_out, fname_without_ext, sprintf('FEMA_wrapper_output_vertex_%s.mat', fstem_imaging));
output_plot_dir = fullfile(dirname_out, fname_without_ext);

if exist(fname_results, 'file')
    load(fname_results);
    disp(['Loaded FEMA results from: ', fname_results]);
else
    error('The specified FEMA results file does not exist: %s', fname_results);
end


% 2) Specify visual preferences for plotting

legendPosition = 'East'; % 'South' or 'East'
title = 1; % whether to include title at top of plot
cm = blueblackred(); % set colormap (preferred: blueblackred or fire)
curvcontrast = [0.2 0.2]; % contrast of gyri/sulci
bgcol = [0 0 0]; % change to [1 1 1] for white background
polarity = 2; % set to 1 for unipolar values e.g. values that range 0 to 1

% 3) Load surface templates for plotting

% In order to plot statistics on a cortical surface, we require a template
% of the cortical surface to project the results onto.  Below we load these
% surface templates.  `SurfView_surfs.mat` contains surfaces for all icos.

load SurfView_surfs.mat % load surface templates
icnum=ico+1; % index for ico number (icnum = ico + 1)
icnvert = size(icsurfs{icnum}.vertices,1); % indices of vertices for specified icosahedral order

% 4) Plot surface-wise statistics for different IVs of interest

% The demo below will produce figures for the IVs (columns of X) from
% the FEMA analysis specfiied by `ncoeff`

for coeffnum = colIDs

      statname = 'z stat'; % specify name of statistic plotting for figure label
      vertvals = zmat(coeffnum,:); % specify statistics to plot

      if ~isempty(thresh_p) && thresh_p ~= 0
          vertvals(abs(vertvals) < -norminv(thresh_p/2)) = nan;
      end
      vertvals_lh = vertvals(1:icnvert); % divide statistics by hemisphere for plotting
      vertvals_rh = vertvals(icnvert+[1:icnvert]);
      
      % specify limits for plot based on vertvals
      fmax = min(300,max(abs(vertvals))); % max limit for plotting purposes
      fmin = 0.0; % min limit for plotting purposes
      fmid = fmax/2; % middle value for plotting purposes
      fvals = [fmin fmid fmax]; % this will be passed to the SurfView_show_new function

      % set colorbar limits - usually [fmin fmax] or [-fmax fmax]
      clim = [-fmax fmax]; 
      
      % Create figure
      % The first two position arguments specify where the figure will
      % appear on the screen; the next two arguments (16 and 10) specify
      % the size of the figure in centimeters - 16 cm wide and 10 cm long
      % is a reasonable choice for an A4 sized paper
      fh = figure('Units', 'centimeters', 'Position', [10 10 32 20], 'Color', bgcol, 'InvertHardcopy', 'off');
      
      % If user wants to number the figure, these two lines should suffice
      % fh = figure(coeffnum + 100*(str2double(dataRelease(1))-3));
      % set(fh, 'Units', 'centimeters', 'Position', [10 10 16 10], 'Color', bgcol, 'InvertHardcopy', 'off');
      
      % Define spacing for axes
      % hvgap controls the horizontal and vertical spaces between the axes
      % btgap controls the space from the bottom of the figure and the top
      % of the figure respectively
      % lrgap controls the space from the left of the figure and the right
      % of the figure respectively
      hvgap = [0.02 0.02];
      if strcmpi(legendPosition, 'south')
          lrgap = [0.02 0.02];
          if title
              btgap = [0.12 0.08];
          else
              btgap = [0.12 0.01];
          end
      else
          if strcmpi(legendPosition, 'east')
              lrgap = [0.02 0.138];
              if title
                  btgap = [0.018 0.08];
              else
                  btgap = [0.018 0.018];
              end
          end
      end
      
      % Create axes
      allH = tight_subplot(3, 2, hvgap, btgap, lrgap);
      %hold(allH(:), 'on');

      axes(allH(1)); SurfView_show_new(surf_lh_pial,surf_rh_pial,vertvals_lh,vertvals_rh,fvals,cm,'left', [1 0],curvvec_lh,curvvec_rh,icsurfs{icnum},polarity,curvcontrast,bgcol); set(gca,'visible','off'); axis tight;
      axes(allH(2)); SurfView_show_new(surf_lh_pial,surf_rh_pial,vertvals_lh,vertvals_rh,fvals,cm,'right',[0 1],curvvec_lh,curvvec_rh,icsurfs{icnum},polarity,curvcontrast,bgcol); set(gca,'visible','off'); axis tight;
      axes(allH(3)); SurfView_show_new(surf_lh_pial,surf_rh_pial,vertvals_lh,vertvals_rh,fvals,cm,'right',[1 0],curvvec_lh,curvvec_rh,icsurfs{icnum},polarity,curvcontrast,bgcol); set(gca,'visible','off'); axis tight;
      axes(allH(4)); SurfView_show_new(surf_lh_pial,surf_rh_pial,vertvals_lh,vertvals_rh,fvals,cm,'left', [0 1],curvvec_lh,curvvec_rh,icsurfs{icnum},polarity,curvcontrast,bgcol); set(gca,'visible','off'); axis tight;
      % Add two additional views
      axes(allH(5)); SurfView_show_new(surf_lh_inflated, surf_rh_inflated, vertvals_lh, vertvals_rh, fvals, cm, 'bottom', [1 0], curvvec_lh, curvvec_rh, icsurfs{icnum}, polarity, curvcontrast, bgcol); 
    %   set(gca, 'visible', 'off'); 
    %   axis tight;  
      axes(allH(6)); SurfView_show_new(surf_lh_inflated, surf_rh_inflated, vertvals_lh, vertvals_rh, fvals, cm, 'bottom', [0 1], curvvec_lh, curvvec_rh, icsurfs{icnum}, polarity, curvcontrast, bgcol); 
    %   set(gca, 'visible', 'off'); 
    %   axis tight;
      

      
      if(title)
          titleAx = axes;
          set(titleAx,'position',[0 0 1 1],'units','normalized');axis off;
          text(titleAx, 0.5,1,sprintf('%s ~ %s [%s]', fstem_imaging, colnames_model{coeffnum}, statname),'color','w','fontweight','bold','interpreter','none','verticalalignment','top','horizontalalignment','center','fontsize',14)
      end

      % Set colorbar
      colormap(cm);
      cb                    = colorbar('color', 'w');
      cb.FontSize           = 10;
      cb.Label.String       = strcat('z-score');
      cb.Label.FontSize     = 12;
      cb.Label.FontWeight   = 'bold';   
      cb.Box                = 'off';
    %   cb.Ticks              = linspace(clim(1), clim(2), 10); % More graduations
    % Update colormap to be black below the threshold values
      if thresh_p ~= 0
        width = -norminv(thresh_p/2) * size(cm, 1) / 2 / fmax;
        nan_range = [ceil(size(cm, 1) / 2 - width) + 1, floor(size(cm, 1) / 2 + width)];
        cm(nan_range(1):nan_range(2), :) = 0.15; % Set to black
      end
      if strcmpi(legendPosition, 'south')
          cb.Location = 'south';
          if title
              cb.Position(1)      = allH(1).Position(1);
              cb.Position(2)      = cb.Position(2) - hvgap(1);
              cb.Position(3)      = allH(1).Position(3)*2 + hvgap(1);
          else
              cb.Position(1)      = allH(1).Position(1);
              cb.Position(2)      = cb.Position(2) - btgap(1);
              cb.Position(3)      = allH(1).Position(3)*2 + hvgap(1);
          end
      else
          if strcmpi(legendPosition, 'east')
              cb.Location = 'eastoutside';
              if title
                  cb.Position(1)      = allH(4).Position(1) + allH(4).Position(3) + 0.01;
                  cb.Position(2)      = allH(3).Position(2);
                  cb.Position(4)      = allH(1).Position(4)*2 + hvgap(1);
              else
                  cb.Position(1)      = allH(4).Position(1) + allH(4).Position(3) + 0.16;
                  cb.Position(2)      = allH(3).Position(2);
                  cb.Position(4)      = allH(1).Position(4)*2 + hvgap(1);
              end
          end
      end
      caxis(clim);
    if thresh_p ~= 0
        plot_filename = fullfile(output_plot_dir, sprintf('Plot_IV_%s_%s_thresh-%.3f.png', fstem_imaging, colnames_model{coeffnum}, thresh_p));
    else
        plot_filename = fullfile(output_plot_dir, sprintf('Plot_IV_%s_%s.png', fstem_imaging, colnames_model{coeffnum}));
    end
    
      % Save the figure
      saveas(fh, plot_filename);  % Save in PNG format
end