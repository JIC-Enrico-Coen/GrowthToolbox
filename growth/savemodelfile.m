function success = savemodelfile( m, savefilename, strip, static, asStage )
%[m,success] = savemodelfile( m, savefilename, strip, static )
%   Save a mesh into a file.
%   This eventually calls save(), but it cannot do only that. Some fields
%   of m cannot sensibly be saved (e.g. function handles), and some values
%   of others should not be saved (e.g. a saved file should not have fields
%   indicating that a movie is in progress. Some fields are generated data
%   which it is unnecessary to save.

global gPlotHandles gUNSAVEDFIELDS;

    if nargin < 5
        asStage = true;
    end

    m.plothandles = gPlotHandles;
    m.pictures = [];
    
    % Finite element definitions are class objects and cannot be saved in
    % .mat files.  Replace each one by its specification.
    if ~isempty(m.FEsets) && isa([m.FEsets.fe],'FiniteElementType')
        for i=1:length(m.FEsets)
            m.FEsets(i).fe = GetSpecification( m.FEsets(i).fe );
        end
    end
    
    m.globalProps.mov = [];
    m.globalProps.allowsave = true;


    isInitial = m.globalDynamicProps.currentIter==0;
    if isInitial || ~asStage
        modelfilename = [ savefilename, '.mat' ];
    else
        stagesuffix = makestagesuffixf( m.globalDynamicProps.currenttime );
        m.stagetimes = addStages( m.stagetimes, m.globalDynamicProps.currenttime );
        modelfilename = [ savefilename, stagesuffix, '.mat' ];
        m.globalDynamicProps.laststagesuffix = stagesuffix;
    end
    
    % Remove the fields that should not be saved.
    unsaved = struct();
    for i=1:length(gUNSAVEDFIELDS)
        fn = gUNSAVEDFIELDS{i};
        if isfield( m, fn )
            unsaved.(fn) = m.(fn);
            m = rmfield( m, fn );
        end
    end

    % Save the leaf into a MAT file, and the static part into the static
    % file.
    [thepath,thebasename,theext] = fileparts( savefilename );
    thename = [thebasename,theext];
    try
        timedFprintf( 1, 'Saving current state to %s in %s\n', ...
            thename, thepath );
        if strip
            m1 = m;
            m = stripmesh(m);
        end
        success = save_7_or_73( modelfilename, m, true );
        if strip
            m = m1;
            clear m1;
        end
    catch le
        success = false;
        warning(le.identifier, '%s', le.message);
        timedFprintf( 1, 'Could not write model file %s to %s.\nModel not saved.\n', ...
            thename, thepath );
    end
    
    % Restore the fields that were not saved.
    fns = fieldnames(unsaved);
    for i=1:length(fns)
        fn = fns{i};
        m.(fn) = unsaved.(fn);
    end
    clear unsaved;

    if success && static
        saveStaticPart( m, savefilename );
    end
end

