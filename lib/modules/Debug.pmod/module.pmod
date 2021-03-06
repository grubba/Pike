#pike __REAL_VERSION__

constant verify_internals = _verify_internals;
constant memory_usage = _memory_usage;
constant gc_status = _gc_status;
constant describe_program = _describe_program;
constant size_object = _size_object;
constant map_all_objects = _map_all_objects;

#if constant(_debug)
// These functions require --with-rtldebug.
constant debug = _debug;
constant optimizer_debug = _optimizer_debug;
constant assembler_debug = _assembler_debug;
constant disassemble = Builtin._disassemble;
constant dump_program_tables = _dump_program_tables;
constant locate_references = _locate_references;
constant describe = _describe;
constant gc_set_watch = _gc_set_watch;
constant dump_backlog = _dump_backlog;
#endif

#if constant(_dmalloc_set_name)
// These functions require --with-dmalloc.
constant reset_dmalloc = _reset_dmalloc;
constant dmalloc_set_name = _dmalloc_set_name;
constant list_open_fds = _list_open_fds;
constant dump_dmalloc_locations = _dump_dmalloc_locations;
#endif

#if constant(_compiler_trace)
// Requires -DYYDEBUG.
constant compiler_trace  = _compiler_trace;
#endif

/* significantly more compact version of size2string */
private string mi2sz( int i )
{
    constant un = ({ "", "k","M","G","T" });
    float x = (float)i;
    int u = 0;
    do
    {
        x /= 1024.0;
        u++;
    } while( x > 1000.0 );
    return sprintf("%.1f%s",x,un[u]);
}

//! Returns a pretty printed version of the output from
//! @[count_objects] (with added estimated RAM usage)
string pp_object_usage()
{
    mapping tmp = ([]);
    int num;
    int total = map_all_objects( lambda( object start )
       {
           num++;
           program q = object_program( start );
           string nam = sprintf("%O",(program)q);
           int memsize = size_object(start);
           sscanf( nam, "object_program(%s)", nam );

           if( !tmp[nam] )
           {
               tmp[nam] = ({1,memsize,Program.defined(q)});
           }
           else
           {
               tmp[nam][0]++;
               tmp[nam][1]+=memsize;
           }
       });

    array by_size = ({});
    foreach( tmp; string obj; array(int) cnt )
    {
        /* some heuristics: Do not show singletons unless it is using a noticeable amount of RAM. */
        if( cnt[1] * cnt[0] < 2048 )
            continue;
        by_size += ({ ({ cnt[1], obj, cnt[0], cnt[2] }) });
    }
    by_size += ({ ({ (total-num)*32, "destructed", (total-num), "-" }) });

    sort( by_size );
    string res = "";
    res += sprintf("-"*(33+6+9+1+21)+"\n"+
                   "%-33s %6s %8s %20s\n"+
                   "-"*(33+6+9+1+21)+"\n",
                   "Object", "Clones","Memory", "Loc");

    foreach( reverse(by_size), [int size, string obj, int cnt, string p] )
        res += sprintf( "%-33s %6d %8s %20s\n", obj[<32..], cnt, mi2sz(size), basename(p||"-"));

    res += ("-"*(33+6+9+1+21)+"\n\n");
    return res;
}

//! Returns a pretty printed version of the
//! output from @[memory_usage].
string pp_memory_usage() {
    string ret="             Num   Bytes\n";
    mapping q = _memory_usage();
    mapping res = ([]), malloc = ([]);
    foreach( q; string key; int val )
    {
        mapping in = res;
        string sub ;
        if( has_suffix( key, "_bytes" ) )
        {
            sub = "bytes";
            key = key[..<6]+"s";
            if( key == "mallocs" )
                key = "malloc";
        }
        if( has_prefix( key, "num_" ) )
        {
            sub = "num";
            key = key[4..];
        }
        if( key == "short_pike_strings" )
            key = "strings";

        if(key == "free_blocks" || key == "malloc" || key == "malloc_blocks" )
            in = malloc;
        if( val )
        {
            if( !in[key] )
                in[key] = ([]);
            in[key][sub] += val;
        }
    }

    string output_one( mapping res, bool trailer )
    {
        array output = ({});
        foreach( res; string key; mapping what )
            output += ({({ what->bytes, what->num, key })});
        output = reverse(sort( output ));

        string format_row( array x )
        {
            return sprintf("%-20s %10s %10d\n", x[2], mi2sz(x[0]), x[1] );
        };

        return
            sprintf("%-20s %10s %10s\n", "Type", "Bytes", "Num")+
            "-"*(21+11+10)+"\n"+
            map( output, format_row )*""+
            "-"*(21+11+10)+"\n"+
            (trailer?
             format_row( ({ Array.sum( column(output,0) ), Array.sum( column(output,1) ), "total" }) ):"");
    };
    return output_one(res,true) + 
        "\nMalloc info:\n"+output_one(malloc,false);
}

//! Returns the number of objects of every kind in memory.
mapping(string:int) count_objects()
{
  mapping(string:int) ret = ([]);
  int num, total;
  total = map_all_objects(lambda(object obj ) {
    string p = sprintf("%O",object_program(obj));
    sscanf(p, "object_program(%s)", p);
    ret[p]++;
    num++;
  });
  if( total > num )
      ret["destructed"] = total-num;
  return ret;
}
