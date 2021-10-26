classdef VRMLWriter < handle
    
    properties
        filename 	% String.  The full path of the output file.
        fileid      % Integer.  The stream id.
        linenumber  % Integer.  The number of the current output line.
        linestack   % List of line numbers.  
        itemstack   % Cell array of item names.
        indentString  % A string of spaces to insert at the beginning of every line.
        indentUnit  % The amount by which to increase the indentation for each level of bracketting.
    end
    
    methods
        function vw = VRMLWriter( varargin )
            vw.clear();
            s = struct( varargin{:} );
            setFromStruct( vw, s, fieldnames(s), 'existing' );
        end
        
        function clear( vw )
            vw.filename = '';
            if ~isempty(vw.fileid) && (vw.fileid ~= -1)
                fclose( vw.fileid );
            end
            vw.fileid = -1;
            vw.linenumber = 0;
            vw.linestack = [];
            vw.itemstack = {};
            vw.indentString = '';
            vw.indentUnit = '    ';
        end
        
        function ok = axesToVRML( filename, ax )
            ok = false;
            if ~ishghandle( ax )
                fprintf( 1, '%s: Invalid axes handle.\n', mfilename() );
                return;
            end
            ok = openfile( vw, filename );
            if ~ok
                return;
            end
            [~,centre] = getAxesBbox( ax );
            cameraparams = getCameraParams( theaxes );
%             scaleParams = struct( 'sizescale', 1, 'thicknessscale', 1, 'allthickness', [], 'thickmin', 0 );
            
            writeVRMLpreamble( vw.fileid, bgcolor );
            writeVRMLViewpoints( fid, cameraparams, 1, centre );
        end
        
        function ok = openfile( vw, filename )
            fid = fopen(filename,'w');
            ok = fid >= 0;
            if ~ok
                fprintf( 1, 'Cannot write to file %s.\n', filename );
            else
                vw.clear();
                vw.filename = filename;
                vw.fileid = fid;
            end
        end
        
        function closefile( vw )
            if vw.fileid >= 0
                fclose( vw.fileid );
                vw.clear();
            end
        end
        
        function writeindent( vw )
            fwrite( fid, vw.indentString );
        end

        function writestring( vw, s )
            if isempty(s)
                fwrite( fid, [ s, char(10) ] );
            else
                fwrite( fid, [ vw.indentString, s, char(10) ] );
            end
            vw.linenumber = vw.linenumber+1;
        end

        function endline( vw, s )
            fwrite( fid, [ s, char(10) ] );
            vw.linenumber = vw.linenumber+1;
        end

        function pushstack( vw, s )
            vw.itemstack{end+1} = s;
            vw.linestack(end+1) = vw.linenumber;
            vw.indentString = repmat( vw.indentUnit, 1, length(vw.itemstack) );
        end

        function popstack( vw, s )
            if ~strcmp( s, vw.itemstack{end} )
                fprintf( 1, '** %s: item ''%d'' on line %d closed by ''%s'' on line %d.\n', ...
                    vw.itemstack{end}, vw.linestack(end), s, vw.linenumber );
            end
            vw.itemstack(end) = []; %  = {vw.itemstack{1:(end-1)}};
            vw.linestack(end) = [];
            vw.indentString = repmat( vw.indentUnit, 1, length(vw.itemstack) );
        end

        function openthing( vw, s, bracket )
            % fwrite( 1, [ vw.indentString, '>> ', s, ' ', bracket, char(10) ] );
            vw.writeindent();
            fwrite( fid, [ s, ' ', bracket, char(10) ] );
            vw.linenumber = vw.linenumber+1;
            vw.pushstack( s );
        end

        function openitem( vw, s )
            vw.openthing( s, '{' );
        end

        function openarray( vw, s )
            vw.openthing( s, '[' );
        end

        function writefield( vw, s )
            vw.writeindent();
            fwrite( fid, [ s, char(10) ] );
            vw.linenumber = vw.linenumber+1;
        end

        function writeface( vw, f )
            vw.writeindent();
            fprintf( fid, '%d ', f );
            vw.endline( '-1' );
        end

        function writearray( vw, fmt, perline, suffix, data )
            numdata = numel(data);
            numlines = numel(data)/perline;
            for ii=perline:perline:numdata
                vw.writeindent();
                fprintf( fid, [fmt, ' '], data( (ii-perline+1):ii ) );
                fwrite( fid, [ suffix, char(10) ] );
            end
            vw.linenumber = vw.linenumber+numlines;
        end

        function closething( vw, s, bracket )
            vw.popstack( s )
            vw.writeindent();
            fwrite( fid, [ bracket, char(10) ] );
            vw.linenumber = vw.linenumber+1;
            % fwrite( 1, [ indentString, '<< ', s, ' ', bracket, char(10) ] );
        end

        function closeitem( vw, s )
            vw.closething( s, '}' )
        end

        function closearray( vw, s )
            vw.closething( s, ']' )
        end

        function writeStdAppearance( vw, thecolor )
            vw.openitem( 'appearance Appearance' );
            vw.openitem( 'material Material' );
            vw.writefield( ['diffuseColor', sprintf( ' %g', thecolor ) ] );
            vw.closeitem( 'material Material' );
            vw.closeitem( 'appearance Appearance' );
        end

        function openShape( vw, pervertex, thecolor, creaseAngle )
            vw.openitem( 'Shape' );
            vw.writeStdAppearance( thecolor );
            vw.openitem( 'geometry IndexedFaceSet' );
            vw.writefield( 'solid TRUE' );
            vw.writefield( 'convex FALSE' );
            vw.writefield( ['creaseAngle ', sprintf( '%g', creaseAngle ), '  # radians'] );
            vw.writefield( [ 'colorPerVertex ', boolchar(pervertex,'TRUE','FALSE') ] );
            vw.openitem( 'coord Coordinate' );
            vw.openarray( 'point' );
        end
    end
end
