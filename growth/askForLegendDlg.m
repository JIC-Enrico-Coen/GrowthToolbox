function varargout = askForLegendDlg(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @askForStringDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @askForStringDlg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
%if nargin && ischar(varargin{1})
%    gui_State.gui_Callback = str2func(varargin{1});
%end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end



% --- Executes just before askForStringDlg is made visible.
function askForStringDlg_OpeningFcn(hObject, eventdata, handles, varargin)
    foreColor = [0.9 1 0.9];
    backColor = [0.4 0.8 0.4];
    setGUIColors( hObject, backColor, foreColor )

% Set the default result of the dialog.
handles.output = [];

% Update handles structure
guidata(hObject, handles);

% Insert custom title, prompt string and initial text.
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'prompt'
          set(handles.staticText, 'String', varargin{index+1});
         case 'initialvalue'
          set(handles.editableText, 'String', varargin{index+1});
        end
    end
end

centreDialog(hObject);

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal');
uicontrol( handles.editableText );
uicontrol( handles.editableText );

% UIWAIT makes askForStringDlg wait for user response (see UIRESUME)
uiwait(handles.figure1);
end



% --- Outputs from this function are returned to the command line.
function varargout = askForStringDlg_OutputFcn(hObject, eventdata, handles)
% Get the result of the dialog.
varargout{1} = handles.output;

% The figure can be deleted now.
delete(hObject);
end

