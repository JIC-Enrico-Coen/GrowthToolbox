function m = setMeshFieldTypes( m )
%m = setMeshFieldTypes( m )
%   WORK IN PROGRESS 2017 Nov.
%   Search for PROBLEM for fields with unresolved issues.

    m.types = addFieldTypes( [], ...
                    'nodes', {'FEVertexes',''}, '', ...
               'tricellvxs', {'FE',''}, 'FEVertexes', ... [96x3 double]
            'vertexnormals', {'FEVertexes',''}, '', ...
                 'edgeends', {'FEEdges',''}, 'FEVertexes', ... [156x2 double]
                'celledges', {'FE',''}, 'FEEdges', ... [96x3 double]
                'edgecells', {'FEEdges',''}, 'FE', ... [156x2 double]
               'sharpedges', {'FEEdges'}, '', ...
                 'sharpvxs', {'FEVertexes'}, '', ...
            'nodecelledges', '', '', ... PROBLEM
                 'nodeFEs', '', '', ... PROBLEM
                'nodeedges', '', '', ... PROBLEM
                'cellareas', 'FE', '', ... [96x1 double]
          'unitcellnormals', {'FE',''}, '', ... [96x3 double]
         'currentbendangle', 'FEEdges', '', ... [156x1 single]
         'initialbendangle', 'FEEdges', '', ... [156x1 single]
                    'seams', 'FEEdges', '', ... 156x1 logical]
               'prismnodes', 'prismnodes', '', ... [122x3 double]
            'displacements', 'prismnodes', '', ... []
                  'FEnodes', 'FEVertexes', '', ... []
           'FEconnectivity', '', '', ... PROBLEM?
      'roleNameToMgenIndex', '', '', ... PROBLEM
              'secondlayer', '', '', ... PROBLEM
        'secondlayerstatic', '', '', ... PROBLEM
               'cellFrames', {'', '', 'FE'}, '', ... [3x3x96 double]
              'cellFramesA', {'', '', 'FE'}, '', ...
              'cellFramesB', {'', '', 'FE'}, '', ...
     'growthanglepervertex', 'FEVertexes', '', ... []
         'growthangleperFE', 'FE', '', ... []
                 'decorFEs', 'FE', '', ... []
                 'decorBCs', {'FE',''}, '', ... []
             'outputcolors', '', '', ... [1x1 struct]
                  'visible', '', '', ... []
                 'plotdata', '', '', ... PROBLEM
                 'pictures', 'pictures', '', ... []
                 'userdata', '', '', ... [1x1 struct]
           'userdatastatic', '', '', ... [1x1 struct]
              'streamlines', '', '', ... []
                  'tubules', '', '', ... []
                'waypoints', '', '', ... []
             'moviescripts', '', '', ... []
            'movieselected', '', '', ... []
              'drivennodes', '', '', ... []
          'drivenpositions', '', '', ... []
            'mgenposcolors', {'','mgens'}, '', ... [3x8 double]
            'mgennegcolors', {'','mgens'}, '', ... [3x8 double]
          'mgenIndexToName', {'','mgens'}, '', ... {'KAPAR'  'KAPER'  'KBPAR'  'KBPER'  'KNOR'  'POLARISER'  'STRAINRET'  'ARREST'}
          'mgenNameToIndex', '', '', ... [1x1 struct]  PROBLEM
          'cellbulkmodulus', 'FE', '', ... [96x1 double]
              'cellpoisson', 'FE', '', ... [96x1 double]
            'cellstiffness', {'','','FE'}, '', ... [6x6x96 double]
          'interactionMode', '', '', ... [1x1 struct]
                'selection', '', '', ... [1x1 struct]
             'plotdefaults', '', '', ... [1x1 struct]
               'morphogens', {'FEVertexes', 'mgens'}, '', ... [61x8 double]
           'morphogenclamp', {'FEVertexes', 'mgens'}, '', ... [61x8 double]
          'mgen_production', {'FEVertexes', 'mgens'}, '', ... [61x8 double]
          'mgen_absorption', {'FEVertexes', 'mgens'}, '', ... [61x8 double]
              'mutantLevel', {'', 'mgens'}, '', ... [1 1 1 1 1 1 1 1]
               'mgenswitch', {'', 'mgens'}, '', ... [1 1 1 1 1 1 1 1]
            'mgen_dilution', {'', 'mgens'}, '', ... [0 0 0 0 0 0 0 0]
       'mgen_transportable', {'', 'mgens'}, '', ... [0 0 0 0 0 0 0 0]
        'mgen_plotpriority', {'', 'mgens'}, '', ... [0 0 0 0 0 0 0 0]
       'mgen_plotthreshold', {'', 'mgens'}, '', ... [0 0 0 0 0 0 0 0]
             'conductivity', {'', 'mgens'}, '', ... [1x8 struct]
          'mgen_interpType', {'', 'mgens'}, '', ... {'mid'  'mid'  'mid'  'mid'  'mid'  'mid'  'mid'  'mid'}
           'transportfield', {'', 'mgens'}, '', ... {[]  []  []  []  []  []  []  []}
               'fixedDFmap', {'prismnodes', ''}, '', ... [122x3 logical]  PROBLEM: special handling of prismnodes.
            'gradpolgrowth', {'FE', ''}, '', ... [96x3 double]
                'polfreeze', {'FE', ''}, '', ... [96x3 double]
              'polfreezebc', {'FE', ''}, '', ... [96x3 double]
                'polfrozen', 'FE', '', ... [96x1 logical]
    'effectiveGrowthTensor', {'FE', ''}, '', ... [96x6 double]
      'directGrowthTensors', {'FE', ''}, '', ... []
                 'celldata', {'','FE'}, '', ... [1x96 struct]
                  'outputs', '', '' ... [1x1 struct]  PROBLEM
        );
end
