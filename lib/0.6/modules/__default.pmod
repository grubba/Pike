/* Compatibility module */

#pike 7.0

//! Pike 0.6 compatibility.
//!
//! The symbols in this namespace will appear in
//! programs that use @tt{#pike 0.6@} or lower.
//!
//! @seealso
//!   @[7.0::]

//! @decl inherit 7.0::

//! More lax types than in later versions.
array(mixed) aggregate(mixed ... args)
{
  return args;
}

object master()
{
  return __REAL_VERSION__::master()->get_compat_master(0, 6);
}

protected Mapping.ShadowedMapping compat_all_constants =
  Mapping.ShadowedMapping(predef::all_constants(),
			  ([
			    "aggregate": aggregate,
			    "all_constants": all_constants,
			    "master": master,
			  ]), 1);

mapping(string:mixed) all_constants()
{
  // Intentional lie in the return type.
  mixed x = compat_all_constants;
  return x;
}
