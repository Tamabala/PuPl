function init

global userInterface
if isgraphics(userInterface)
    uimenu(findobj(userInterface, 'Tag', 'importEventLogsMenu'),...
        'Label', 'From &Presentation .log file',...
        'Interruptible', 'off',...
        'Callback', @(h, e)...
            updateglobals('eventLogs',...
                'append',...
                @loadpresentationlog,...
                1));
end

end