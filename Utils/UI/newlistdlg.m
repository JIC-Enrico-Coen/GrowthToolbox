function [selection,ok] = newlistdlg( varargin )
% This is a reimplementation of the MATLAB listdlg() using my dialog layout
% system.  The arguments are identical to those for listdlg():
%
%   'ListString'    cell array of strings for the list box.
%   'SelectionMode' string; can be 'single' or 'multiple'; defaults to
%                   'multiple'.
%   'ListSize'      [width height] of listbox in pixels; defaults
%                   to [160 300].
%   'InitialValue'  vector of indices of which items of the list box
%                   are initially selected; defaults to the first item.
%   'Name'          String for the figure's title; defaults to ''.
%   'PromptString'  string matrix or cell array of strings which appears 
%                   as text above the list box; defaults to {}.
%   'OKString'      string for the OK button; defaults to 'OK'.
%   'CancelString'  string for the Cancel button; defaults to 'Cancel'.

    s = struct();
    for i=1:2:length(varargin)
        s.(varargin{i}) = varargin{i+1};
    end
    s = defaultfields( s, ...
        'ListString', {''}, ...
        'SelectionMode', 'multiple', ...
        'ListSize', [160 300], ...
        'InitialValue', 1, ...
        'Name', '', ...
        'PromptString', '', ...
        'OKString', 'OK', ...
        'CancelString', 'Cancel' );
    result = performRSSSdialogFromFile( 'listdialog.txt', s, [], @setDefaultGUIColors );
    ok = ~isempty(result);
    if ok
        selection = result.choices.values;
    else
        selection = [];
    end
end