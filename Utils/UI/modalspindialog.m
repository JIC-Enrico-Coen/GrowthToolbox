function [ok,result,dialogresult] = modalspindialog( lastValues )
    result = struct( 'numFrames', 0, 'whichaxis', 0, 'waveangle', 0, 'globalaxis', 0, 'cycles', 0 );
    ok = false;
    axistags = { 'xaxis' 'yaxis' 'zaxis' ...
                 'majoraxis' 'middleaxis' 'minoraxis' ...
                 'camerasightaxis' 'camerarightaxis' 'cameraupaxis' };
    modetags = { 'oscButton' 'spinButton' };

    foreColor = [0.9 1 0.9];
    backColor = [0.4 0.8 0.4];

    dialogresult = performRSSSdialogFromFile( 'spinlayout.txt', ...
        lastValues, ...
        [], ...
        @(h)setGUIColors( h, backColor, foreColor ) );
    
    if isempty(dialogresult)
        return;
    end
    
    whichaxis = find( strcmp( dialogresult.axisButtonGroup, axistags ), 1 );
    
    dospin = find( strcmp( dialogresult.oscButtonGroup, modetags ), 1 )==2;
    
    numFrames = round( str2double( dialogresult.numFramesText ) );
    if isnan(numFrames) || (numFrames <= 0)
        fprintf( 1, 'The number of frames must be positive, value found was %d. No gyration performed.\n', numFrames )
        return;
    end
    tiltangle = str2double( dialogresult.tiltangleText );
    if isnan(tiltangle)
        tiltangle = 0;
    end
    waveangle = str2double( dialogresult.waveangleText );
    if (isnan(waveangle) || (waveangle==0)) && ~dospin && (tiltangle==0)
        fprintf( 1, 'Oscillation selected but no oscillation or tilt angles provided. No gyration performed.\n' )
        return;
    end
    cycles = round( str2double( dialogresult.cyclesText ) );
    if isnan(cycles) || (cycles <= 0)
        cycles = 1;
    end
    
    result = struct( 'frames', numFrames, ...
                     'whichaxis', whichaxis, ...
                     'waveangle', waveangle, ...
                     'tiltangle', tiltangle, ...
                     'cycles', cycles, ...
                     'dospin', dospin );
    ok = true;
end
