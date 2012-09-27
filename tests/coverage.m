//
//  coverage.m
//  AGImageChecker
//
//  Created by Angel Garcia on 9/27/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#include <stdio.h>

FILE *fopen$UNIX2003(const char * __restrict, const char * __restrict);
FILE *fopen$UNIX2003( const char *filename, const char *mode )
{
    return fopen(filename, mode);
}

size_t fwrite$UNIX2003(const void * __restrict, size_t, size_t, FILE * __restrict);
size_t fwrite$UNIX2003( const void *a, size_t b, size_t c, FILE *d )
{
    return fwrite(a, b, c, d);
}