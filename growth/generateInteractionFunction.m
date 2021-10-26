function generateInteractionFunction( fid, m, userCodeSections )
%generateInteractionFunction( fid, m, userCodeSections )
%   Create a new interaction function for a project that does not have one.

    ifname = makeIFname( m.globalProps.modelname );
    if isempty(ifname)
        complain( 'generateInteractionFunction: no model name.  Cannot make interaction function.' );
        return;
    end
    if nargin < 3
        need_setproperties = true;
        userCodeSections = defaultUserCodeSections( m );
    else
        need_setproperties = (~isfield( userCodeSections, 'subfunctions')) ...
            || isempty( userCodeSections.subfunctions );
        userCodeSections = defaultFromStruct( ...
            userCodeSections, defaultUserCodeSections( m ) );
    end
    need_setproperties = false; 
    
    coderevinfo = sprintf( '%%   Written at %s.\n%%   GFtbox revision %d, %s.', ...
             datestr(clock,'yyyy-mm-dd HH:MM:SS'), ...
             m.globalProps.coderevision, ...
             m.globalProps.coderevisiondate );
    if m.globalProps.modelrevision==0
        modelrevinfo = '';
    else
        modelrevinfo = '';
%         modelrevinfo = sprintf( '%%   Model last saved by GFtbox revision %d, %s.\n', ...
%              m.globalProps.modelrevision, ...
%              m.globalProps.modelrevisiondate );
    end
    
    if m.globalProps.newcallbacks
        ifresults = '[m,result]';
        ifargs = '( m, varargin )';
    else
        ifresults = 'm';
        ifargs = '( m )';
    end
    
    preamble1a = ...
      { [ 'function ', ifresults, ' = ', ifname, ifargs ], ...
        [ '%', ifresults, ' = ', ifname, ifargs ], ...
        '%   Morphogen interaction function.', ...
        coderevinfo, ...
        modelrevinfo ...
        };
    if m.globalProps.newcallbacks
        preamble1b = loadIFtemplate( 'if_before_user_init2' );
    else
        preamble1b = loadIFtemplate( 'if_before_user_init' );
    end
    
    if isVolumetricMesh( m )
        % Need to add something here;
        preamble2 = loadIFtemplate( 'if_volmgens' );
        systematic_mgen_range = 1:length(m.mgenIndexToName);
    else
        preamble2 = loadIFtemplate( 'if_newmgens' );
        % Should look up role indexes.
        systematic_mgen_range = [1:5 7:length(m.mgenIndexToName)];
    end
    
    if isVolumetricMesh(m)
        postamble1 = loadIFtemplate( 'if_endinit_vol' );
    else
        postamble1 = loadIFtemplate( 'if_endinit_new' );
    end

    printstrings( fid, preamble1a );
    printstrings( fid, preamble1b );
    fwrite( fid, userCodeSections.init );
    printstrings( fid, preamble2 );

    for i=systematic_mgen_range
        n = m.mgenIndexToName{i};
        ln = lower(n);
        fprintf( fid, ...
            '    [%s_i,%s_p,%s_a,%s_l] = getMgenLevels( m, ''%s'' );  %%#ok<ASGLU>\n', ...
            ln, ln, ln, ln, n );
    end
    
    numcellfactors = size( m.secondlayer.cellvalues, 2 );
    if numcellfactors > 0
        for i=1:numcellfactors
            n = index2Name( m.secondlayer.valuedict, i );
            if ~isempty(n)
                ln = lower(n);
                fprintf( fid, ...
                    '    [%s_i,%s] = getCellFactorLevels( m, ''%s'' );\n', ...
                    ln, ln, n );
            end
        end
    end
    
    if isfield( m.secondlayer, 'vvlayer' )
        numVVmgens = length( m.secondlayer.vvlayer.mgendict.indexToName );
        for i=1:numVVmgens
            n = m.secondlayer.vvlayer.mgendict.indexToName{i};
            ln = n; % lower(n);
            fprintf( fid, ...
                '    [i_%s,c_%s,m_%s,w_%s,a_%s,cl_%s,ml_%s,wl_%s] = getVVMgenLevels( m, ''%s'' );  %%#ok<ASGLU>\n', ...
                ... % '    [%s_i,%s_c,%s_m,%s_w,%s_a,%s_cl,%s_ml,%s_wl] = getVVMgenLevels( m, ''%s'' );\n', ...
                ln, ln, ln, ln, ln, ln, ln, ln, n );

        end
    end

    writeMeshInfo( fid, m );
    
    printstrings( fid, loadIFtemplate( 'if_begin_interaction' ) );

    fwrite( fid, userCodeSections.mid );
    printstrings( fid, postamble1 );

    for i=systematic_mgen_range
        n = m.mgenIndexToName{i};
        ln = lower(n);
        fprintf( fid, ...
            '    m.morphogens(:,%s_i) = %s_p;\n', ...
            ln, ln );
    end

    numcellfactors = size( m.secondlayer.cellvalues, 2 );
    if numcellfactors > 0
        for i=1:numcellfactors
            n = index2Name( m.secondlayer.valuedict, i );
            if ~isempty(n)
                ln = lower(n);
                fprintf( fid, '    m.secondlayer.cellvalues(:,%s_i) = %s(:);\n', ln, ln );
            end
        end
    end
    
    if isfield( m.secondlayer, 'vvlayer' )
        numVVmgens = length( m.secondlayer.vvlayer.mgendict.indexToName );
        for i=1:numVVmgens
            n = m.secondlayer.vvlayer.mgendict.indexToName{i};
            ln = n; % lower(n);
            fprintf( fid, '    m.secondlayer.vvlayer.mgenC(:,i_%s) = c_%s;\n', ln, ln );
            fprintf( fid, '    m.secondlayer.vvlayer.mgenM(:,i_%s) = m_%s;\n', ln, ln );
            fprintf( fid, '    m.secondlayer.vvlayer.mgenW(:,i_%s) = w_%s;\n', ln, ln );
        end
    end
    
    printstrings( fid, ...
        { '', ...
          '%%% USER CODE: FINALISATION', ...
          userCodeSections.final, ...
          '%%% END OF USER CODE: FINALISATION' } );
    printstrings( fid, ...
        { '', ...
          'end', ...
          '' } );
      
    if m.globalProps.newcallbacks
        printstrings( fid, ...
            { 'function [m,result] = ifCallbackHandler( m, fn, varargin )', ...
              '    result = [];', ...
              '    if exist(fn,''file'') ~= 2', ...
              '        return;', ...
              '    end', ...
              '    [m,result] = feval( fn, m, varargin{:} );', ...
              'end', ...
              '' } );
    end
      
    printstrings( fid, ...
        { '', ...
          '%%% USER CODE: SUBFUNCTIONS' } );
      
    if need_setproperties
        dumpGlobalPropsToIF( fid, m );
    end

    fwrite( fid, userCodeSections.subfunctions );
end

function dumpGlobalPropsToIF( fid, m )
    fns = fieldnames( m.globalProps );
    fwrite( fid, loadIFtemplate( 'if_initproperties' ) );
    nfns = length(fns);
    for i=1:nfns
        fn = fns{i};
        val = m.globalProps.(fn);
        if ischar( val )
            fprintf( fid, '%%    m = leaf_setproperty( m, ''%s'', ''%s'' );\n', fn, unesc(val) );
        else
            n = numel(val);
            if n==0
                fprintf( fid, '%%    m = leaf_setproperty( m, ''%s'', [] );\n', fn );
            elseif n==1
                if islogical( val )
                    if val
                        fprintf( fid, '%%    m = leaf_setproperty( m, ''%s'', true );\n', fn );
                    else
                        fprintf( fid, '%%    m = leaf_setproperty( m, ''%s'', false );\n', fn );
                    end
                elseif isinteger( val )
                    fprintf( fid, '%%    m = leaf_setproperty( m, ''%s'', %d );\n', fn, val );
                elseif isreal( val )
                    fprintf( fid, '%%    m = leaf_setproperty( m, ''%s'', %f );\n', fn, val );
                else
                    fprintf( fid, '%%    m = leaf_setproperty( m, ''%s'', (unknown type ''''%s'''') );\n', fn, class(val) );
                end
            else
                fprintf( fid, '%%    m = leaf_setproperty( m, ''%s'', (%d values) );\n', fn, n );
            end
        end
    end
    fprintf( fid, 'end\n' );
end

function s = unesc(s)
%unescape s so that it can appear as the contents of a Matlab string constant.
    s = regexprep( s, '''', '''''' );
end