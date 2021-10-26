function boing()
    f = which(mfilename());
    dir = fileparts(fileparts(f));
    boingfile = fullfile( fullfile( dir, 'Boings' ), 'boing.wav' );
    try
        [a,fs] = wavread( boingfile );
        max(a)
        min(a)
      % wavplay(a*0.1,12000);
        sound(a*0.1,12000);
    catch exc
        fprintf( 1, 'Could not play boing file %s\n', boingfile );
        exc
    end
end
