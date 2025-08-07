function c = emptyfecell()
%     tensorLength = 6;

    c.cellThermExpGlobalTensor = []; % zeros( tensorLength, 1 );
    c.eps0gauss = [];
    c.gnGlobal = [];
    c.displacementStrain = [];
    c.residualStrain = [];
    c.actualGrowthTensor = [];
    % c.fixed = 0;
    c.vorticity = [];
    c.Glocal = [];
    c.Gglobal = [];
end
