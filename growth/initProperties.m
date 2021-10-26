function m = initProperties( m )
%m = initProperties( m )
%   Set to a default state many fields of m that affect the simulation.
%   This is convenient to call from your interaction function at time zero,
%   before initialising the mesh with the values you want.
%
%   The following fields are set:
%       morphogens              all set to 0
%       mgen_production         all set to 0
%       mgen_absorption         all set to 0
%       mgen_dilution           all set to 0
%       mgenswitch              all set to 1
%       mutantLevel             all set to 1
%       allMutantEnabled        true

    m.morphogens(:) = 0;
    m.mgen_production(:) = 0;
    m.mgen_absorption(:) = 0;
    m.mutantLevel(:) = 1;
    m.allMutantEnabled = 1;
    m.mgen_dilution(:) = 0;
    m.mgenswitch(:) = 1;
end
