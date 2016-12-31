# Release Notes and Changes

## Version 0.4 Changes

- Eliminated optional final arguments (#111) - there is now no built-in method for pre-allocation. This may need to be added in the future with a different syntax depending on needs.
- Switched from using the @pomdp_func macro and throwing errors to declaring empty generic functions for the interface (#110)
- Added requirements infrastructure (#117)
