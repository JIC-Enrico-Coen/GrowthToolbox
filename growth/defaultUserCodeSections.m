function userCodeSections = defaultUserCodeSections( m )
    userCodeSections.init = loadIFtemplate( 'if_user_init' );
    if m.globalProps.newoptionmethod
        userCodeSections.init = loadIFtemplate( 'if_user_init2' );
    else
        userCodeSections.init = loadIFtemplate( 'if_user_init' );
    end
    userCodeSections.mid = loadIFtemplate( 'if_user_mid' );
    userCodeSections.final = loadIFtemplate( 'if_user_final' );
    userCodeSections.subfunctions = loadIFtemplate( 'if_user_subfunctions' );
end
