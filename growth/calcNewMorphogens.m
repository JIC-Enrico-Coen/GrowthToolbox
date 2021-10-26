function newm = calcNewMorphogens( oldm )
    OLD_K_PAR = 1; 
    OLD_K_PER = 2;
    OLD_K_POL = 3;
    OLD_B_PAR = 4;
    OLD_B_PER = 5;
    OLD_B_POL = 6;
    OLD_ARREST = 7;
    OLD_STRAINRET = 8;
    OLD_THICKNESS = 9;

    Kpar = oldm(:,OLD_K_PAR);
    Kper = oldm(:,OLD_K_PER);
    Bendpar = oldm(:,OLD_B_PAR);
    Bendper = oldm(:,OLD_B_PER);

    Aparabs = Kpar + Bendpar;
    Bparabs = Kpar - Bendpar;
    Kparzero = Kpar==0;
    Aparrel(Kparzero) = 0;
    Aparrel(~Kparzero) = Aparabs(~Kparzero) ./ Kpar(~Kparzero);
    Bparrel(Kparzero) = 0;
    Bparrel(~Kparzero) = Bparabs(~Kparzero) ./ Kpar(~Kparzero);

    Aperabs = Kper + Bendper;
    Bperabs = Kper - Bendper;
    Kperzero = Kper==0;
    Aperrel(Kperzero) = 0;
    Aperrel(~Kperzero) = Aperabs(~Kperzero) ./ Kper(~Kperzero);
    Bperrel(Kperzero) = 0;
    Bperrel(~Kperzero) = Bperabs(~Kperzero) ./ Kper(~Kperzero);

    newm = [ ...
        Kpar, ...
        Kper, ...
        oldm( :, OLD_THICKNESS ), ...
        oldm( :, OLD_K_POL ), ...
        Aparrel(:), ...
        Aperrel(:), ...
        Bparrel(:), ...
        Bperrel(:), ...
        oldm( :, OLD_STRAINRET ), ...
        oldm( :, OLD_ARREST )
    ];
end
