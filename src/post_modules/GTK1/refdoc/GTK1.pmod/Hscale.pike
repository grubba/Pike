//! The GTK1.HScale widget is used to allow the user to select a value
//! using a horizontal slider. A GTK1.Adjustment is used to set the
//! initial value, the lower and upper bounds, and the step and page
//! increments.
//! 
//! See W(Scale) for details
//! 
//! The position to show the current value, and the number of decimal
//! places shown can be set using the parent W(Scale) class's
//! functions.
//! 
//!@expr{ GTK1.Hscale(GTK1.Adjustment())->set_usize(300,30)@}
//!@xml{<image>../images/gtk1_hscale.png</image>@}
//!
//!
//!

inherit GTK1.Scale;

protected GTK1.Hscale create( GTK1.Adjustment settings );
//! Used to create a new hscale widget.
//! The adjustment argument can either be an existing W(Adjustment), or
//! 0, in which case one will be created for you. 
//!
//!
