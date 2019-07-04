function pupl_UI

% The UI layout is stored in this file

global userInterface

userInterface = figure('Name', '',...
    'NumberTitle', 'off',...
    'UserData', struct(...
        'dataCount', 0,...
        'activeEyeDataIdx', logical([])),...
    'CloseRequestFcn', @savewarning,...
    'MenuBar', 'none',...
    'ToolBar', 'none',...
    'Visible', 'on');
set(userInterface, 'SizeChangedFcn', @preservelayout);

%% Active datasets
sbw = 0.03;
oripos = [0 0 1 1];
uibuttongroup(userInterface,...
    'Title', 'Active data',...
    'FontSize', 10,...
    'Tag', 'activeEyeDataPanel',...
    'Units', 'normalized',...
    'Position', oripos,...
    'UserData', struct(...
        'OriginalPos', oripos));
uicontrol('Style','Slider','Parent',1,...
    'Tag', 'dataScroller',...
    'Units','normalized','Position',[1 - sbw 0 sbw 1],...
    'Value',1,'Callback',@(h,e) scrolldatapanel(h,e));
set(userInterface, 'WindowScrollWheelFcn', @(h,e) scrolldatapanel(h,e));

%% File menu
fileMenu = uimenu(userInterface,...
    'Tag', 'fileMenu',...
    'Label', '&File');
uimenu(fileMenu,...
    'Label', '&Load',...
    'Callback', @(h, e)...
        updateglobals(...
            'eyeData',...
            'append',...
            @() pupl_load,...
            1));
uimenu(fileMenu,...
    'Tag', 'importEyeDataMenu',...
    'Label', '&Import');
uimenu(fileMenu,...
    'Label', '&Save',...
    'UserData', @() isnonemptyfield(getactive('eye data')),...
    'Callback', @(src, event)...
        updateglobals([], [],...
            @() pupl_save('type', 'eye data', 'data', getactive('eye data')), []));
uimenu(fileMenu,...
    'Label', '&Batch save',...
    'UserData', @() isnonemptyfield(getactive('eye data')),...
    'Callback', @(src, event)...
        updateglobals([], [],...
            @() pupl_save('type', 'eye data', 'data', getactive('eye data'), 'batch', true), []));
uimenu(fileMenu,...
    'Label', '(De)select &all data',...
    'Tag', 'selectAllData',...
    'Separator', 'on',...
    'UserData', @() numel(evalin('base', 'eyeData')) > 0,...
    'Callback', @(src, event) selectalldata);
uimenu(fileMenu,...
    'Label', '&Remove datasets',...
    'UserData', @() dataexists('eye data'),...
    'Callback', @(src, event)...
        updateglobals([], [],...
            @() deleteinactive('eye data'), []));
uimenu(fileMenu,...
    'Label', 'R&eload raw data',...
    'UserData', @() isnonemptyfield(getactive('eye data')),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() arrayfun(@(x) x.getraw(), (getactive('eye data'))),...
            1));
uimenu(fileMenu,...
    'Label', 'Save &processing script',...
    'Separator', 'on',...
    'UserData', @() isnonemptyfield(getactive('eye data')),...
    'Callback', @(src, event) pupl_history('wt'));

%% Processing menu
processingMenu = uimenu(userInterface,...
    'Label', '&Process',...
    'UserData', @() isnonemptyfield(getactive('eye data')));
uimenu(processingMenu,...
    'Label', '&Normalize data',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() pupl_normalize(getactive('eye data')),...
            1));
trimmingMenu = uimenu(processingMenu,...
    'Label', '&Trim data');
uimenu(trimmingMenu,...
    'Label', 'Trim extreme &dilation values',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() trimdiam(getactive('eye data')),...
            1));
uimenu(trimmingMenu,...
    'Label', 'Trim extreme &gaze values',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'gaze', 'x'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() trimgaze(getactive('eye data')),...
            1));
uimenu(trimmingMenu,...
    'Label', 'Trim &isolated samples',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() trimshort(getactive('eye data')),...
            1));
uimenu(trimmingMenu,...
    'Label', 'Trim &blink-adjacent samples',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() trimblinkadjacent(getactive('eye data')),...
            1));
filterMenu = uimenu(processingMenu,...
    'Label', 'Moving average &filter');
uimenu(filterMenu,...
    'Label', 'Pupil &diameter',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() eyefilter(getactive('eye data'), 'dataType', 'Dilation'),...
            1));
uimenu(filterMenu,...
    'Label', '&Gaze',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'gaze', 'x'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() eyefilter(getactive('eye data'), 'dataType', 'Gaze', 'filterType', 'median'),...
            1));
saccadesMenu = uimenu(processingMenu,...
    'Label', 'Identify &saccades and fixations',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'gaze', 'x'));
uimenu(saccadesMenu,...
    'Label', '&Velocity threshold',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'gaze', 'x'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() velocitythresholdsaccadeID(getactive('eye data')),...
            1));
uimenu(saccadesMenu,...
    'Label', '&Dispersion threshold',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'gaze', 'x'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() dispersionsaccadeID(getactive('eye data')),...
            1));
uimenu(processingMenu,...
    'Label', 'Map gaze data to fixation &centroids',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() maptofixationcentroid(getactive('eye data')),...
            1));
PFEmenu = uimenu(processingMenu,...
    'Label', 'Pupil foreshortening &error correction');
uimenu(PFEmenu,...
    'Label', '&Linear detrend in gaze y-axis',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left') &...
        isnonemptyfield(getactive('eye data'), 'gaze', 'y'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() PFEdetrend(getactive('eye data'), 'axis', 'y'),...
            1));
uimenu(PFEmenu,...
    'Label', '&Quadratic detrend in gaze x-axis',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left') &...
        isnonemptyfield(getactive('eye data'), 'gaze', 'y'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() PFEdetrend(getactive('eye data'), 'axis', 'x'),...
            1));
uimenu(PFEmenu,...
    'Label', 'Automatic PFE correction (beta)',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left') &...
        isnonemptyfield(getactive('eye data'), 'gaze', 'y'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() PFEcorrection(getactive('eye data')),...
            1));
interpMenu = uimenu(processingMenu,...
    'Label', '&Interpolate missing data',...
    'UserData', @() isnonemptyfield(getactive('eye data')));
uimenu(interpMenu,...
    'Label', 'Pupil &diameter',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() interpeyedata(getactive('eye data'), 'data', 'diam'),...
            1));
uimenu(interpMenu,...
    'Label', '&Gaze',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'gaze', 'x'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() interpeyedata(getactive('eye data'), 'data', 'gaze'),...
            1));
uimenu(processingMenu,...
    'Label', '&Merge left and right diameter streams',...
    'UserData', @() isnonemptyfield(getactive('eye data')),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() pupl_mergelr(getactive('eye data'), 'diamlr'),...
            1));
uimenu(processingMenu,...
    'Label', '&Run pipeline',...
    'Separator', 'on',...
    'UserData', @() isnonemptyfield(getactive('eye data')),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() pupl_pipeline(getactive('eye data')),...
            1));

%% Trials menu
trialsMenu = uimenu(userInterface,...
    'Label', '&Trials',...
    'UserData', @() isnonemptyfield(getactive('eye data')));
%% Event logs menu
eventLogsMenu = uimenu(trialsMenu,...
    'Label', '&Event logs');
importEventLogsMenu = uimenu(eventLogsMenu,...
    'Tag', 'importEventLogsMenu',...
    'Label', '&Import');
uimenu(importEventLogsMenu,...
    'Label', 'From &BIDS-compliant TSV',...
    'Interruptible', 'off',...
    'Callback', @(h, e)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() pupl_importraw(...
                'eyedata', getactive('eye data'),...
                'loadfunc', @tsv2eventlog,...
                'type', 'event'),...
            1));
uimenu(eventLogsMenu,...
    'Label', '&Synchronize with eye data',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'eventlog'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() attachevents(getactive('eye data')),...
            1));
%% Misc trial stuff
uimenu(trialsMenu,...
    'Label', 'Define and mark &higher-order events',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Separator', 'on',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() definehigherorderevents(getactive('eye data')),...
            1));
uimenu(trialsMenu,...
    'Label', 'Compute &reaction times',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Separator', 'on',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() computereactiontimes(getactive('eye data')),...
            1));
%% Event-related pupillometry menu
pupillometryMenu = uimenu(trialsMenu,...
    'Label', 'Event-related &pupillometry',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'event'));
uimenu(pupillometryMenu,...
    'Label', '&Fragment continuous data into trials',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Separator', 'on',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() pupl_epoch(getactive('eye data')),...
            1));
uimenu(pupillometryMenu,...
    'Label', '&Baseline correction',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'epoch'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() baselinecorrection(getactive('eye data')),...
            1));
trialRejectionMenu = uimenu(pupillometryMenu,...
    'Label', 'Trial &rejection',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'epoch'));
% Rejection sub-menu
uimenu(trialRejectionMenu,...
    'Label', 'Reject by &missing data',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'epoch'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() rejecttrialsbymissingppn(getactive('eye data')),...
            1));
%{
uimenu(trialRejectionMenu,...
    'Label', 'Reject by &blink proximity',...
    'Enable', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() rejecttrialsbyblinkproximity(getactive('eye data')),...
            1));
uimenu(trialRejectionMenu,...
    'Label', 'Reject by e&xtreme dilation',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'epoch'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() rejectbyextremevalues(getactive('eye data')),...
            1));
%}
uimenu(trialRejectionMenu,...
    'Label', '&Un-reject trials',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'epoch'),...
    'Separator', 'on',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() unreject(getactive('eye data')),...
            1));
uimenu(pupillometryMenu,...
    'Label', '&Merge trials into sets',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'epoch'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() createtrialsets(getactive('eye data')),...
            1));
uimenu(pupillometryMenu,...
    'Label', 'Write &statistics to spreadsheet',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'trialset'),...
    'Callback', @(src, event)...
        pupl_stats(getactive('eye data')));
%% Gaze tracking menu
gazeTrackingMenu = uimenu(trialsMenu,...
    'Label', '&Gaze tracking',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'event'));
defineAOImenu = uimenu(gazeTrackingMenu,...
    'Label', '&Define areas of interest',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'event'));
uimenu(defineAOImenu,...
    'Label', '&Rectangular',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'event'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() defineAOIs(getactive('eye data'), 'type', 'rect'),...
            1));
uimenu(defineAOImenu,...
    'Label', '&Polygonal',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'event'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() defineAOIs(getactive('eye data'), 'type', 'poly'),...
            1));
uimenu(defineAOImenu,...
    'Label', '&Circular',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'event'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() defineAOIs(getactive('eye data'), 'type', 'circ'),...
            1));
uimenu(defineAOImenu,...
    'Label', '&Elliptical',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'event'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() defineAOIs(getactive('eye data'), 'type', 'ellipse'),...
            1));
uimenu(gazeTrackingMenu,...
    'Label', '&Compute stats',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'datalabel'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() computeAOIstats(getactive('eye data')),...
            1));
uimenu(gazeTrackingMenu,...
    'Label', '&Group AOIs into sets',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'aoi'),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() defineAOIsets(getactive('eye data')),...
            1));
uimenu(gazeTrackingMenu,...
    'Label', '&Write AOI statistics to spreadsheet',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'aoi', 'stats'),...
    'Callback', @(src, event)...
        writeAOIstats(getactive('eye data')));
%% Experiment menu
experimentMenu = uimenu(userInterface,...
    'Label', '&Experiment',...
    'UserData', @() isnonemptyfield(getactive('eye data')));
uimenu(experimentMenu,...
    'Label', '&Assign datasets to conditions',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() pupl_condition(getactive('eye data')),...
            1));

%% Plotting menu
plottingMenu = uimenu(userInterface,...
    'Label', 'P&lot',...
    'UserData', @() isnonemptyfield(getactive('eye data')));
scrollMenu = uimenu(plottingMenu,...
    'Label', 'Plot &continuous');
uimenu(scrollMenu,...
    'Label', 'P&upil dilation',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Callback', @(src, event)...
        plotforeach(getactive('eye data'), @pupl_scrollplot, 'type', 'diam'));
        % plotcontinuous(getactive('eye data'), 'type', 'dilation'));
uimenu(scrollMenu,...
    'Label', 'Ga&ze',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'gaze', 'x'),...
    'Callback', @(src, event)...
        plotforeach(getactive('eye data'), @pupl_scrollplot, 'type', 'gaze'));
        % plotcontinuous(getactive('eye data'), 'type', 'gaze'));
uimenu(plottingMenu,...
    'Label', '&Gaze scatterplot',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'gaze'),...
    'Callback', @(src, event) gazescatter(getactive('eye data')));
uimenu(plottingMenu,...
    'Label', '&Pupil diameter histogram',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam'),...
    'Callback', @(src, event)...
        plotforeach(getactive('eye data'), @pupilsizehist));
PFEplotmenu = uimenu(plottingMenu,...
    'Label', 'Pupil &foreshortening error',...
    'UserData', @() isnonemptyfield(getactive('eye data')));
uimenu(PFEplotmenu,...
    'Label', 'Pupil size vs gaze &y',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'gaze', 'y'),...
    'Callback', @(src, event)...
        PFEdetrend(getactive('eye data'), 'axis', 'y', 'vis', 'yes', 'proc', 'no'));
uimenu(PFEplotmenu,...
    'Label', 'Pupil size vs gaze &x',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'gaze', 'y'),...
    'Callback', @(src, event)...
        PFEdetrend(getactive('eye data'), 'axis', 'x', 'vis', 'yes', 'proc', 'no'));
uimenu(PFEplotmenu,...
    'Label', 'Error &surface',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Callback', @(h, e)...
        plotforeach(getactive('eye data'), @PFEplot, 'error'));
uimenu(plottingMenu,...
    'Label', 'Plot &trials',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'epoch'),...
    'Callback', @(src, event)...
        plottrials(getactive('eye data')));
plotTrialSetsMenu = uimenu(plottingMenu,...
    'Label', 'Plot trial &sets',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'trialset'));
uimenu(plotTrialSetsMenu,...
    'Label', '&Line plot',...
    'Callback', @(src, event)...
        plottrialaverages(getactive('eye data')));
uimenu(plotTrialSetsMenu,...
    'Label', '&Heatmap',...
    'Callback', @(src, event)...
        eyeheatmap(getactive('eye data')));
%% BIDS menu
bidsmenu = uimenu(userInterface,...
    'Label', '&BIDS');
uimenu(bidsmenu,...
    'Label', '&Load sourcedata',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            'append',...
            @() loadBIDSsourcedata,...
            1));
uimenu(bidsmenu,...
    'Label', 'Add BIDS &info',...
    'UserData', @() isnonemptyfield(getactive('eye data')),...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            getfield(get(userInterface, 'UserData'), 'activeEyeDataIdx'),...
            @() addBIDSinfo(getactive('eye data')),...
            1));
uimenu(bidsmenu,...
    'Label', 'Run &pipeline on sourcedata',...
    'Callback', @(src, event) processBIDSsourcedata);
savebidsmenu = uimenu(bidsmenu,...
    'Label', '&Save',...
    'UserData', @() isnonemptyfield(getactive('eye data')));
uimenu(savebidsmenu,...
    'Label', 'Save &raw from current data',...
    'UserData', @() isnonemptyfield(getactive('eye data')),...
    'Callback', @(src, event) writeBIDS(getactive('eye data'), 'types', 'raw'));
uimenu(savebidsmenu,...
    'Label', 'Save &current data as sourcedata',...
    'UserData', @() isnonemptyfield(getactive('eye data')),...
    'Callback', @(src, event) writeBIDS(getactive('eye data'), 'types', 'sourcedata-current'));
uimenu(savebidsmenu,...
    'Label', 'Reload raw of current data and save as sourcedata',...
    'UserData', @() isnonemptyfield(getactive('eye data')),...
    'Callback', @(src, event) writeBIDS(getactive('eye data'), 'types', 'sourcedata'));
uimenu(savebidsmenu,...
    'Label', 'Save current data as &derivative',...
    'UserData', @() isnonemptyfield(getactive('eye data')),...
    'Callback', @(src, event) writeBIDS(getactive('eye data'), 'types', 'derivatives'));

update_UI;

end

function scrolldatapanel(ignored, eventdata)

dataPanel = findobj('Tag', 'activeEyeDataPanel');
dataScroller = findobj('Tag', 'dataScroller');
originalDataPanelPos = getfield(get(dataPanel, 'UserData'), 'OriginalPos');
if originalDataPanelPos(2) >= 0
    set(dataScroller, 'Value', 1);
else
    if isempty(eventdata) % Octave
        eventdata = struct('EventName', 'action');
    end
    switch lower(eventdata.EventName)
        case 'windowscrollwheel'
            currVert = get(dataScroller, 'Value');
            scroll = eventdata.VerticalScrollCount * eventdata.VerticalScrollAmount;
            newVert = currVert - scroll/100;
            if newVert < 0
                scroll = currVert * 100;
            elseif newVert > 1
                scroll = (currVert - 1) * 100;
            end
            newVert = currVert - scroll/100;
            set(dataScroller, 'Value', newVert);
        case 'action'
            newVert = get(dataScroller, 'Value');
    end
    originalDataPanelPos(2) = newVert * originalDataPanelPos(2);
    set(dataPanel, 'Position', originalDataPanelPos);
end

end