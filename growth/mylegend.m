function varargout = mylegend(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @legend_OpeningFcn, ...
                   'gui_OutputFcn',  @legend_OutputFcn, ...
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


% --- Executes just before legend is made visible.
function legend_OpeningFcn(hObject, eventdata, handles, varargin)
    % Choose default command line output for legend
    handles.output = -1;

    % Update handles structure
    guidata(hObject, handles);

    centreDialog(hObject);
    set(handles.figure1,'WindowStyle','modal');
    uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = legend_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;

    % The figure can be deleted now.
    delete(hObject);


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)


% --- Executes on button press in okbutton.
function okbutton_Callback(hObject, eventdata, handles)


% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)


