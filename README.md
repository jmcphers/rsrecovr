# RsRecovr

RsRecovr: Recover unsaved files from RStudio sessions

## What is it?

RStudio has an auto-save feature which keeps internal copies of files as
they're edited. However, certain kinds of crashes or [RStudio state
resets](https://support.rstudio.com/hc/en-us/articles/200534577-Resetting-RStudio-Desktop-s-State)
can make these copies inaccessible from RStudio itself. If you had a file open
in RStudio and never manually closed it, there is a good chance RStudio has a
backup.

This is an R package which extracts files from those backups. It can help you
restore files you've accidentally deleted or unsaved changes lost in a crash.

## Usage

There's just one exported function in this package, `recovr`. It has three forms.

### Recovering Projects

The simplest (and most common) form is project recovery. Just run this:

```r
rsrecovr::recovr()
```

In this mode, RsRecovr will restore all the files that were open in the current
project. The "current project" is inferred from the current working directory;
use the `project_path` argument to supply a different directory.

It's important to understand that this operates on the files that were open in
the project session, not necessarily files in the project *itself*. 

### Recovering Other Files

If you don't use RStudio Projects, or had a file open without being in a
project (i.e. RStudio shows `(None)` as the open project), don't fret! Specify
a `NULL` project path to restore these files.

```r
rsrecovr::recovr(project_path = NULL)
```

### Recovering Everything

In the worst case, you might not remember which project you had open when you
were editing the file you wanted to recover. If that's the case, you can ask
RsRecover to dump *everything*.


```r
rsrecovr::recovr(project_path = "all")
```

In this mode, RsRecovr will look your list of recently used projects (the same
one that shows you your Recent Projects in RStudio). It will then recover files
from every one of these projects, *and* all the files not associated with a
project (as in `project_path = NULL`). 


