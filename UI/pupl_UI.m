function pupl_UI

% The UI layout is stored in this file

global userInterface

userInterface = figure('Name', 'Pupillometry',...
    'NumberTitle', 'off',...
    'UserData', struct(...
        'dataCount', 0,...
        'eventLogCount', 0,...
        'activeEyeDataIdx', logical([]),...
        'activeEventLogsIdx', logical([])),...
    'SizeChangedFcn', @preservelayout,...
    'CloseRequestFcn', @savewarning,...
    'MenuBar', 'none',...
    'ToolBar', 'none',...
    'Visible', 'off');

% Active datasets
uibuttongroup('Title', 'Active datasets',...
    'Tag', 'activeEyeDataPanel',...
    'Position',[0.01 0.01 .48 0.95],...
    'FontSize', 10);
uibuttongroup('Title', 'Active event logs',...
    'Tag', 'activeEventLogsPanel',...
    'Position',[0.51 0.01 .48 0.95],...
    'FontSize', 10);

% File menu
fileMenu = uimenu(userInterface,...
    'Tag', 'fileMenu',...
    'Label', '&File');
importMenu = uimenu(fileMenu,...
    'Tag', 'importEyeDataMenu',...
    'Label', '&Import');
uimenu(fileMenu,...
    'Label', '&Load',...
    'Callback', @(h, e)...
        updateglobals(...
            'eyeData',...
            'append',...
            @() pupl_load('type', 'eye data'),...
            1));
uimenu(fileMenu,...
    'Label', '&Save',...
    'UserData', @() isnonemptyfield(getactive('eye data')),...
    'Callback', @(src, event)...
        updateglobals([], [],...
            @() pupl_save('type', 'eye data', 'data', getactive('eye data')), []));
uimenu(fileMenu,...
    'Label', '&Remove inactive datasets',...
    'UserData', @() dataexists('eye data'),...
    'Separator', 'on',...
    'Callback', @(src, event)...
        updateglobals([], [],...
            @() deleteinactive('eye data'), []));

% Processing menu
processingMenu = uimenu(userInterface,...
    'Label', '&Process',...
    'UserData', @() isnonemptyfield(getactive('eye data')));
trimmingMenu = uimenu(processingMenu,...
    'Label', '&Trim data');
uimenu(trimmingMenu,...
    'Label', 'Trim extreme &dilation values',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() trimdiam(getactive('eye data')),...
            1));
uimenu(trimmingMenu,...
    'Label', 'Trim extreme &gaze values',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'gaze', 'x'),...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() trimgaze(getactive('eye data')),...
            1));
uimenu(trimmingMenu,...
    'Label', 'Trim &isolated samples',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() trimshort(getactive('eye data')),...
            1));
blinksMenu = uimenu(processingMenu,...
    'Label', '&Blinks');
uimenu(blinksMenu,...
    'Label', 'Identify &blinks',...
    'Enable', 'off',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() identifyblinks(getactive('eye data')),...
            1));
uimenu(blinksMenu,...
    'Label', 'Delete &blink samples',...
    'Enable', 'off',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() deleteblinks(getactive('eye data')),...
            1));
filterMenu = uimenu(processingMenu,...
    'Label', '&Filter');
uimenu(filterMenu,...
    'Label', '&Dilation data',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() eyefilter(getactive('eye data'), 'dataType', 'Dilation'),...
            1));
uimenu(filterMenu,...
    'Label', '&Gaze data',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'gaze', 'x'),...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() eyefilter(getactive('eye data'), 'dataType', 'Gaze', 'filterType', 'median'),...
            1));
uimenu(processingMenu,...
    'Label', '&Interpolate',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() interpeyedata(getactive('eye data')),...
            1));
uimenu(processingMenu,...
    'Label', '&Merge left and right streams',...
    'UserData', @() isnonemptyfield(getactive('eye data')),...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() mergelr(getactive('eye data'), 'diamlr'),...
            1));
PFEmenu = uimenu(processingMenu,...
    'Label', 'Pupil foreshortening &error correction');
uimenu(PFEmenu,...
    'Label', '&Linear detrend in gaze y-axis',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left') &...
        isnonemptyfield(getactive('eye data'), 'gaze', 'y'),...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() PFEdetrend(getactive('eye data'), 'axis', 'y'),...
            1));
uimenu(PFEmenu,...
    'Label', '&Quadratic detrend in gaze x-axis',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left') &...
        isnonemptyfield(getactive('eye data'), 'gaze', 'y'),...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() PFEdetrend(getactive('eye data'), 'axis', 'x'),...
            1));
uimenu(PFEmenu,...
    'Label', 'Automatic PFE correction (beta)',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left') &...
        isnonemptyfield(getactive('eye data'), 'gaze', 'y'),...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() PFEcorrection(getactive('eye data')),...
            1));

% Trials menu
trialsMenu = uimenu(userInterface,...
    'Label', '&Trials',...
    'UserData', @() isnonemptyfield(getactive('eye data')));
% Event logs sub-menu
eventLogsMenu = uimenu(trialsMenu,...
    'Label', '&Event logs');
uimenu(eventLogsMenu,...
    'Label', '&Write to eye data',...
    'UserData', @() isnonemptyfield(getactive('event logs')),...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() attachevents(getactive('eye data'),...
                'eventLogs', getactive('event logs')),...
            1));
importEventLogsMenu = uimenu(eventLogsMenu,...
    'Tag', 'importEventLogsMenu',...
    'Label', '&Import',...
    'Separator', 'on');
uimenu(eventLogsMenu,...
    'Label', '&Load',...
    'Callback', @(src, event)...
        updateglobals('eventLogs',...
            'append',...
            @() pupl_load('type', 'event logs'),...
            1));
uimenu(eventLogsMenu,...
    'Label', '&Save',...
    'UserData', @() isnonemptyfield(getactive('event logs')),...
    'Callback', @(src, event)...
        updateglobals([], [],...
            @() pupl_save('type', 'event logs', 'data', getactive('eye data')), []));
uimenu(eventLogsMenu,...
    'Label', '&Remove inactive event logs',...
    'UserData', @() dataexists('event logs'),...
    'Separator', 'on',...
    'Callback', @(src, event)...
        updateglobals([], [],...
            @() deleteinactive('event logs'), []));
% The rest of the trials menu
uimenu(trialsMenu,...
    'Label', '&Fragment continuous data into trials',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Interruptible', 'off',...
    'Separator', 'on',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() pupl_epoch(getactive('eye data')),...
            1));
trialRejectionMenu = uimenu(trialsMenu,...
    'Label', 'Trial &rejection');
% Rejection sub-menu
uimenu(trialRejectionMenu,...
    'Label', 'Reject by &missing data',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'epoch'),...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() rejecttrialsbymissingppn(getactive('eye data')),...
            1));
uimenu(trialRejectionMenu,...
    'Label', 'Reject by &blink proximity',...
    'Enable', 'off',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() rejecttrialsbyblinkproximity(getactive('eye data')),...
            1));
uimenu(trialRejectionMenu,...
    'Label', 'Reject by e&xtreme dilation',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'epoch'),...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() rejectbyextremevalues(getactive('eye data')),...
            1));
uimenu(trialRejectionMenu,...
    'Label', '&Un-reject trials',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'epoch'),...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() unreject(getactive('eye data')),...
            1));

uimenu(trialsMenu,...
    'Label', '&Merge trials into sets',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'epoch'),...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() binepochs(getactive('eye data')),...
            1));
    
% Experiment menu
experimentMenu = uimenu(userInterface,...
    'Label', '&Experiment',...
    'UserData', @() isnonemptyfield(getactive('eye data')));
uimenu(experimentMenu,...
    'Label', '&Assign datasets to conditions',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            'append',...
            @() pupl_condition(getactive('eye data')),...
            1));

% Plotting menu
plottingMenu = uimenu(userInterface,...
    'Label', 'P&lot',...
    'UserData', @() isnonemptyfield(getactive('eye data')));
scrollMenu = uimenu(plottingMenu,...
    'Label', 'Plot &continuous');
uimenu(scrollMenu,...
    'Label', 'P&upil dilation',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'left'),...
    'Callback', @(src, event)...
        plotcontinuous(getactive('eye data'), 'type', 'dilation'));
uimenu(scrollMenu,...
    'Label', 'Ga&ze',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'gaze', 'x'),...
    'Callback', @(src, event)...
        plotcontinuous(getactive('eye data'), 'type', 'gaze'));
uimenu(plottingMenu,...
    'Label', 'Plot &trials',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'epoch'),...
    'Callback', @(src, event)...
        plottrials(getactive('eye data')));
plotTrialSetsMenu = uimenu(plottingMenu,...
    'Label', 'Plot trial &sets',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'bin'));
uimenu(plotTrialSetsMenu,...
    'Label', '&Line plot',...
    'Callback', @(src, event)...
        plottrialaverages(getactive('eye data')));
uimenu(plotTrialSetsMenu,...
    'Label', '&Heatmap',...
    'Callback', @(src, event)...
        eyeheatmap(getactive('eye data')));
uimenu(plottingMenu,...
    'Label', 'Pupil &foreshortening error surface',...
    'UserData', @() isnonemptyfield(getactive('eye data'), 'diam', 'x'),...
    'Callback', @(h, e)...
        UI_getPFEsurfaceparams(getactive('eye data')));

% Spreadsheet menu
spreadSheetMenu = uimenu(userInterface,...
    'Label', '&Spreadsheet',...
    'UserData', @() isnonemptyfield(getactive('eye data')));
uimenu(spreadSheetMenu,...
    'Label', '&Write eye data to spreadsheet',...
    'Callback', @(src, event)...
        writetospreadsheet(getactive('eye data')));

update_UI;

end