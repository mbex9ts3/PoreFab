function maximize(hFig)
%MAXIMIZE: function which maximizes the figure withe the input handle
%   Through integrated Java functionality, the input figure gets maximized
%   depending on the current screen size.

if nargin < 1
    hFig = gcf;             % default: current figure
end
drawnow                     % required to avoid Java errors
jFig = get(handle(hFig), 'JavaFrame'); 
jFig.setMaximized(true);
end