#!/usr/bin/env pike

inherit "lib.pike";

int main(int argc, array(string) argv)
{
  if(sscanf(argv[-1],"%*[a-zA-Z]:%*s")==2)
  {
    argv[0]="copy";
    exit(do_cmd( Array.map(argv,fixpath)));
  }else{
    exece(find_next_in_path(argv[0],"cp"),argv[1..]);
    exit(69);
  }
}