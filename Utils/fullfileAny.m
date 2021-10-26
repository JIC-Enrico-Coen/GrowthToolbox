function f = fullfileAny( computertype, varargin )
% This is a version of Matlab's fullfile() that takes the computer type as its
% first argument. If COMPUTERTYPE begins with 'PC', it will use '\' as the file
% separator, otherwise '/'.
%
% This is needed when you are constructing full path names for a remote machine
% whose type is known, and may not be the same as that of the local machine.
%
% See also: FULLFILE

    narginchk(1, Inf);
    fileSeparator = filesepAny( computertype ); % This is the only difference between this file and fullfile.m

    theInputs = varargin;

    containsCellOrStringInput = false;
    containsStringInput = false; 

    for i = 1:length( theInputs )

        inputElement = theInputs{i};
        
        containsCellOrStringInput = containsCellOrStringInput || iscell(inputElement);
        
        if isstring(inputElement)
            containsStringInput = true; 
            containsCellOrStringInput = true; 
            theInputs{i} = convertStringsToChars(theInputs{i});
        end
    
        if ~ischar(theInputs{i}) && ~iscell(theInputs{i}) && ~isnumeric(theInputs{i}) && ~isreal(theInputs{i})
            error(message('MATLAB:fullfile:InvalidInputType'));
        end

    end
    
    f = theInputs{1};
    try
        if nargin == 1
            if ~isnumeric(f)
                f = refinePath(f, fileSeparator);
            else 
                f = char(f); 
            end
        else
            if containsCellOrStringInput
                theInputs(cellfun(@(x)~iscell(x)&&isempty(x), theInputs)) = [];
            else
                theInputs(cellfun('isempty', theInputs)) = '';
            end

            if length(theInputs)>1
                theInputs{1} = ensureTrailingFilesep(theInputs{1}, fileSeparator);
            end
            if ~isempty(theInputs)
                theInputs(2,:) = {fileSeparator};
                theInputs{2,1} = '';
                theInputs(end) = '';
                if containsCellOrStringInput
                    f = strcat(theInputs{:});
                else
                    f = [theInputs{:}];
                end
            end
            f = refinePath(f,fileSeparator);
        end
    catch
        locHandleError(theInputs(1,:));
    end
    
    if containsStringInput
        f = string(f);
    end
end


function f = ensureTrailingFilesep(f,fileSeparator)
    if iscell(f)
        for i=1:numel(f)
            f{i} = addTrailingFileSep(f{i},fileSeparator);
        end
    else
        f = addTrailingFileSep(f,fileSeparator);
    end
end

function str = addTrailingFileSep(str, fileSeparator)
    persistent bIsPC
    if isempty (bIsPC)
        bIsPC = ispc;
    end
    if ~isempty(str) && (str(end) ~= fileSeparator && ~(bIsPC && str(end) == '/'))
        str = [str, fileSeparator];
    end
end
function f = refinePath(f, fs)
    persistent singleDotPattern multipleFileSepPattern
       
    if isempty(singleDotPattern)
        singleDotPattern = [fs, '.', fs];
        multipleFileSepPattern = [fs, fs];
    end   
    
    f = strrep(f, '/', fs);

    if any(contains(f, singleDotPattern))
        f = replaceSingleDots(f, fs);
    end

    if any(contains(f, multipleFileSepPattern))
        f = replaceMultipleFileSeps(f, fs);
    end

    if any(contains(f,':'))
        f = fixIRI(f,fs);
    end
    
end

function f = replaceMultipleFileSeps(f, fs)    
    persistent fsEscape multipleFileSepRegexpPattern 
    if isempty(fsEscape)
        fsEscape = ['\', fs];
        fileIRI = ['(file:(' fsEscape '{1,2}))'];
        generalIRI = ['(\w{2,}:' fsEscape ')'];
        if ispc
            drive = '([a-zA-Z]:)';
            winUNC = '(\\)';
            longname = '(\\\\\?\\.*)';
            multipleFileSepRegexpPattern = ['^(' drive '|' longname '|' winUNC '|' fileIRI '|' generalIRI ')|(\\)\\+'];
        else
            multipleFileSepRegexpPattern = ['^(' fileIRI '|' generalIRI ')|(', fsEscape, ')', fsEscape '+'];
        end
    end
    f = regexprep(f, multipleFileSepRegexpPattern , '$1', 'ignorecase');
end

function f = fixIRI(f,fs)
    needMultipleSlash = startsWith(f,'file:','IgnoreCase',true);
    pattern = ['^(\w{2,}:\' fs ')\' fs '*'];
    rep = ['$1\' fs];
    if ischar(f)
        if(~needMultipleSlash)
            f = regexprep(f, pattern , rep);
        end
    else
        f(~needMultipleSlash) = regexprep(f(~needMultipleSlash),pattern,rep);
    end
end

function f = replaceSingleDots(f, fs)   
    persistent fsEscape singleDotRegexpPattern
    if isempty(fsEscape)
        fsEscape = ['\', fs];
        if ispc
            singleDotRegexpPattern = '(^\\\\(\?\\.*|\.(?=\\)))|(\\)(?:\.\\)+';
        else
            singleDotRegexpPattern = ['(',fsEscape,')', '(?:\.', fsEscape, ')+'];
        end
    end
    f = regexprep(f, singleDotRegexpPattern, '$1');
end

function locHandleError(theInputs)
    firstNonscalarCellArg = struct('idx', 0, 'size', 0);
    for argIdx = 1:numel(theInputs)
        currentArg = theInputs{argIdx};
        if isscalar(currentArg)
            continue;
        elseif ischar(currentArg) && ~isrow(currentArg) && ~isempty(currentArg)
            throwAsCaller(MException(message('MATLAB:fullfile:NumCharRowsExceeded')));
        elseif iscell(currentArg)
            currentArgSize = size(currentArg);
            if firstNonscalarCellArg.idx == 0
                firstNonscalarCellArg.idx = argIdx;
                firstNonscalarCellArg.size = currentArgSize;
            elseif ~isequal(currentArgSize, firstNonscalarCellArg.size)
                throwAsCaller(MException(message('MATLAB:fullfile:CellstrSizeMismatch')));
            end
        end
    end
    throwAsCaller(MException(message('MATLAB:fullfile:InvalidInputType')));
end