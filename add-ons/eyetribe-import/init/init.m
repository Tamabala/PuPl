function init

pupl_UI_addimporter(...
    'loadfunc', @readeyetribe_txt,...
    'label', '(beta) From &EyeTribe (.txt)')

pupl_UI_addimporter(...
    'loadfunc', @readeyetribe_csv,...
    'type', 'event',...
    'label', 'From &EyeTribe (.csv)')

end