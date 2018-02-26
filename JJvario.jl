module JJvario
export save_kernel, load_kernel
#---------------------------------------------------------------------------------------------------
function serializewrite( fname :: String 
                       , data )
    fname = split(fname, ".jls")[1]
    fname = split(fname, "__jversion_")[1]
    jls_file  = open( string( fname
                            , "__jversion_"
                            , replace( string(VERSION)
                                     , "."
                                     , "_"
                                     )
                            , ".jls"
                            )
                    , "w"
                    )
    serialize( jls_file
             , data
             )
    close(jls_file)
end
#---------------------------------------------------------------------------------------------------
function save_kernel(filename)
    namespace = names(Main)
    # masking out the modules
    mask = typeof.(eval.(namespace)) .!= Module
    # masking out the user defined functions (these don't need to be saved)
    mask .*= map(x -> x[1], string.(typeof.(eval.(namespace)))) .!= '#'
    
    outdict = Dict()
    for name in namespace[mask]
        outdict[name] = eval(name)
    end
    serializewrite(filename, outdict)
end
#---------------------------------------------------------------------------------------------------
function serializeread( fname :: String )

    if !( string( replace( string(VERSION)
                         , "."
                         , "_"
                         )
                , ".jls"
                )
          ==
          split(fname, "__jversion_")[2]
        )
        error( string( "Attempting to read serialized file generated by a different version of "
                     , "Julia . . . you will need to remake the file =("
                     )
             )
    end

    return deserialize(open(fname, "r"))
end
#---------------------------------------------------------------------------------------------------
function load_kernel(filename)
    indict = serializeread(filename)
    for (k,v) in zip(keys(indict),values(indict))
        exp = :($k = $v)
        eval(exp)
    end
end
#---------------------------------------------------------------------------------------------------
end
