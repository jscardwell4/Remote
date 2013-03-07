//
// iPhontoMacros.h
// iPhonto
//
// Created by Jason Cardwell on 6/13/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#define DefaultDDLogLevel LOG_LEVEL_WARN

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lumberjack Extensions
////////////////////////////////////////////////////////////////////////////////

#define EDITOR_LOG_CONTEXT     (1 << 3)
#define PAINTER_LOG_CONTEXT    (1 << 4)
#define NETWORKING_LOG_CONTEXT (1 << 5)
#define REMOTE_LOG_CONTEXT     (1 << 6)
#define COREDATA_LOG_CONTEXT   (1 << 7)
#define UITESTING_LOG_CONTEXT  (1 << 8)
#define CONSTRAINT_LOG_CONTEXT (1 << 9)

#define EDITOR_LC     EDITOR_LOG_CONTEXT
#define PAINTER_LC    PAINTER_LOG_CONTEXT
#define NETWORKING_LC NETWORKING_LOG_CONTEXT
#define REMOTE_LC     REMOTE_LOG_CONTEXT
#define COREDATA_LC   COREDATA_LOG_CONTEXT
#define UITESTING_LC  UITESTING_LOG_CONTEXT
#define CONSTRAINT_LC CONSTRAINT_LOG_CONTEXT

#define REMOTE_F       REMOTE_LC
#define REMOTE_C       CONSOLE_LC
#define REMOTE_F_C     REMOTE_LC|CONSOLE_LC
#define PAINTER_F      PAINTER_LC
#define PAINTER_C      CONSOLE_LC
#define PAINTER_F_C    PAINTER_LC|CONSOLE_LC
#define COREDATA_F     COREDATA_LC
#define COREDATA_C     CONSOLE_LC
#define COREDATA_F_C   COREDATA_LC|CONSOLE_LC
#define NETWORKING_F   NETWORKING_LC
#define NETWORKING_C   CONSOLE_LC
#define NETWORKING_F_C NETWORKING_LC|CONSOLE_LC
#define EDITOR_F       EDITOR_LC
#define EDITOR_C       CONSOLE_LC
#define EDITOR_F_C     EDITOR_LC|CONSOLE_LC
#define UITESTING_F    UITESTING_LC
#define UITESTING_C    CONSOLE_LC
#define UITESTING_F_C  UITESTING_LC|CONSOLE_LC
#define CONSTRAINT_F   CONSTRAINT_LC
#define CONSTRAINT_C   CONSOLE_LC
#define CONSTRAINT_F_C CONSTRAINT_LC|CONSOLE_LC

