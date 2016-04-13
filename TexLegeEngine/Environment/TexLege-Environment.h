//
//  TexLege-Environment.h
//  TexLege
//
//  Created by Gregory Combs on 3/30/15
//  Copyright (c) 2014 TexLege. All rights reserved.
//

#define IS_DEBUG_BUILD   (  defined(DEBUG)  )
#define IS_RELEASE_BUILD (  defined(NDEBUG) || !defined(DEBUG)  )

#if IS_DEBUG_BUILD
    #define TARGETING_STAGING
    #define IF_STAGING(stagingValue, productionValue) stagingValue
#else
    #define TARGETING_PRODUCTION
    #define IF_STAGING(stagingValue, productionValue) productionValue
#endif
