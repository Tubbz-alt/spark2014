------------------------------------------------------------------
-- Tokeneer ID Station Core Software
--
-- Copyright (2003) United States Government, as represented
-- by the Director, National Security Agency. All rights reserved.
--
-- This material was originally developed by Praxis High Integrity
-- Systems Ltd. under contract to the National Security Agency.
------------------------------------------------------------------

------------------------------------------------------------------
-- ConfigData
--
-- Description:
--    Implementation of ConfigData package
--
------------------------------------------------------------------
with Clock;
use type Clock.DurationT;

with PrivTypes;
use type PrivTypes.ClassT;

with AuditTypes;
use type AuditTypes.FileSizeT;

package body ConfigData
--# own State is
--#    LatchUnlockDuration,
--#    AlarmSilentDuration,
--#    FingerWaitDuration,
--#    TokenRemovalDuration,
--#    EnclaveClearance,
--#    WorkingHoursStart,
--#    WorkingHoursEnd,
--#    MaxAuthDuration,
--#    AccessPolicy,
--#    MinEntryClass,
--#    MinPreservedLogSize,
--#    AlarmThresholdSize,
--#    SystemMaxFar &
--# FileState is ConfigFile;
is

   ------------------------------------------------------------------
   -- Types
   --
   ------------------------------------------------------------------

   subtype AlarmSilentTextI is Positive range 1..20;
   subtype AlarmSilentTextT is String(AlarmSilentTextI);

   subtype LatchUnlockTextI is Positive range 1..20;
   subtype LatchUnlockTextT is String(LatchUnlockTextI);

   subtype TokenRemovalTextI is Positive range 1..21;
   subtype TokenRemovalTextT is String(TokenRemovalTextI);

   subtype FingerWaitTextI is Positive range 1..19;
   subtype FingerWaitTextT is String(FingerWaitTextI);

   subtype ClearanceTextI is Positive range 1..17;
   subtype ClearanceTextT is String(ClearanceTextI);

   subtype WorkingStartTextI is Positive range 1..18;
   subtype WorkingStartTextT is String(WorkingStartTextI);

   subtype WorkingEndTextI is Positive range 1..16;
   subtype WorkingEndTextT is String(WorkingEndTextI);

   subtype MaxAuthDurationTextI is Positive range 1..16;
   subtype MaxAuthDurationTextT is String(MaxAuthDurationTextI);

   subtype MinEntryClassTextI is Positive range 1..14;
   subtype MinEntryClassTextT is String(MinEntryClassTextI);

   subtype AccessPolicyTextI is Positive range 1..13;
   subtype AccessPolicyTextT is String(AccessPolicyTextI);

   subtype MinPreservedLogSizeTextI is Positive range 1..20;
   subtype MinPreservedLogSizeTextT is String(MinPreservedLogSizeTextI);

   subtype AlarmThresholdTextI is Positive range 1..19;
   subtype AlarmThresholdTextT is String(AlarmThresholdTextI);

   subtype SystemMaxFarTextI is Positive range 1..13;
   subtype SystemMaxFarTextT is String(SystemMaxFarTextI);

   AlarmSilentTitle         : constant AlarmSilentTextT
     := "ALARMSILENTDURATION ";
   LatchUnlockTitle         : constant LatchUnlockTextT
     := "LATCHUNLOCKDURATION ";
   TokenRemovalTitle        : constant TokenRemovalTextT
     := "TOKENREMOVALDURATION ";
   FingerWaitTitle          : constant FingerWaitTextT
     := "FINGERWAITDURATION ";
   ClearanceTitle           : constant ClearanceTextT
     := "ENCLAVECLEARANCE ";
   WorkingStartTitle        : constant WorkingStartTextT
     := "WORKINGHOURSSTART ";
   WorkingEndTitle          : constant WorkingEndTextT
     := "WORKINGHOURSEND ";
   MaxAuthDurationTitle     : constant MaxAuthDurationTextT
     := "MAXAUTHDURATION ";
   AccessPolicyTitle        : constant AccessPolicyTextT
     := "ACCESSPOLICY ";
   MinEntryClassTitle       : constant MinEntryClassTextT
     := "MINENTRYCLASS ";
   MinPreservedLogSizeTitle : constant MinPreservedLogSizeTextT
     := "MINPRESERVEDLOGSIZE ";
   AlarmThresholdTitle      : constant AlarmThresholdTextT
     := "ALARMTHRESHOLDSIZE ";
   SystemMaxFarTitle      : constant SystemMaxFarTextT
     := "SYSTEMMAXFAR ";

   subtype ClassTextI is Positive range 1..12;
   subtype ClassTextT is String(ClassTextI);

   type ClassStringT is record
      Text   : ClassTextT;
      Length : ClassTextI;
   end record;

   type ClassStringLookUpT is array (PrivTypes.ClassT) of ClassStringT;
   ClassStringLookUp : constant ClassStringLookUpT :=
     ClassStringLookUpT'
     (PrivTypes.Unmarked     => ClassStringT'("unmarked    ", 8),
      PrivTypes.UnClassified => ClassStringT'("unclassified", 12),
      PrivTypes.Restricted   => ClassStringT'("restricted  ", 10),
      PrivTypes.Confidential => ClassStringT'("confidential", 12),
      PrivTypes.Secret       => ClassStringT'("secret      ", 6),
      PrivTypes.TopSecret    => ClassStringT'("topsecret   ", 9));

   subtype AccessTextI is Positive range 1..12;
   subtype AccessTextT is String(AccessTextI);

   type AccessStringT is record
      Text   : AccessTextT;
      Length : AccessTextI;
   end record;

   type AccessStringLookUpT is array (AccessPolicyT) of AccessStringT;
   AccessStringLookUp : constant AccessStringLookUpT :=
     AccessStringLookUpT'
     (AllHours     => AccessStringT'("allhours    ", 8),
      WorkingHours => AccessStringT'("workinghours", 12));

   ------------------------------------------------------------------
   -- State
   --
   ------------------------------------------------------------------
   LatchUnlockDuration  : DurationT;
   AlarmSilentDuration  : DurationT;
   FingerWaitDuration   : DurationT;
   TokenRemovalDuration : DurationT;
   EnclaveClearance     : PrivTypes.ClassT;
   WorkingHoursStart    : Clock.DurationT;
   WorkingHoursEnd      : Clock.DurationT;
   MaxAuthDuration      : Clock.DurationT;
   AccessPolicy         : AccessPolicyT;
   MinEntryClass        : PrivTypes.ClassT;
   MinPreservedLogSize  : AuditTypes.FileSizeT;
   AlarmThresholdSize   : AuditTypes.FileSizeT;
   SystemMaxFar         : IandATypes.FarT;

   ConfigFile : File.T := File.NullFile;
   ------------------------------------------------------------------
   -- Public Operations
   --
   ------------------------------------------------------------------

   ------------------------------------------------------------------
   -- ValidateFile
   --
   -- Implementation Notes:
   --      None.
   --
   ------------------------------------------------------------------
   procedure ValidateFile
     (TheFile                 : in out File.T;
      Success                 :    out Boolean;
      TheLatchUnlockDuration  :    out DurationT;
      TheAlarmSilentDuration  :    out DurationT;
      TheFingerWaitDuration   :    out DurationT;
      TheTokenRemovalDuration :    out DurationT;
      TheEnclaveClearance     :    out PrivTypes.ClassT;
      TheWorkingHoursStart    :    out Clock.DurationT;
      TheWorkingHoursEnd      :    out Clock.DurationT;
      TheMaxAuthDuration      :    out Clock.DurationT;
      TheAccessPolicy         :    out AccessPolicyT;
      TheMinEntryClass        :    out PrivTypes.ClassT;
      TheMinPreservedLogSize  :    out AuditTypes.FileSizeT;
      TheAlarmThresholdSize   :    out AuditTypes.FileSizeT;
      TheSystemMaxFar         :    out IandATypes.FarT
      )
   is

      OK : Boolean;

      ------------------------------------------------------------------
      -- ReadDuration
      --
      -- Description:
      --      Reads a Duration from file.
      --
      -- Implementation Notes:
      --      Within the file duration is stored in seconds,
      --      convert to 1/10sec for storage.
      ------------------------------------------------------------------
      procedure ReadDuration( Value : out DurationT)
        --# global in out TheFile;
        --#           out Success;
        --# derives TheFile,
        --#         Value,
        --#         Success from TheFile;
      is
         RawDuration : Integer;
      begin

         Value := DurationT'First;
         File.GetInteger(TheFile, RawDuration, 0, Success);

         --------------------------------------------------------------
         -- The original Tokeneer code had a defect in the following
         -- condition. See the Reader's Guide for an explantion and
         -- root-cause analysis
         --
         --    if Success and then
         --      (RawDuration * 10 <= Integer(DurationT'Last) and
         --       RawDuration * 10 >= Integer(DurationT'First)) then
         --------------------------------------------------------------

         if Success and then
           (RawDuration <= Integer (DurationT'Last) / 10 and
              RawDuration >= Integer (DurationT'First) / 10) then

            Value := DurationT(RawDuration * 10);
         else
            Success := False;
         end if;

         if File.EndOfLine(TheFile) then
            File.SkipLine(TheFile, 1);
         else
            Success := False;
         end if;

      end ReadDuration;


      ------------------------------------------------------------------
      -- ReadFileSize
      --
      -- Description:
      --      Reads an audit file size from file.
      --
      -- Implementation Notes:
      --      Within the file size is stored in Kbytes,
      --      convert to bytes for storage.
      ------------------------------------------------------------------
      procedure ReadFileSize( Value : out AuditTypes.FileSizeT)
        --# global in out TheFile;
        --#           out Success;
        --# derives TheFile,
        --#         Value,
        --#         Success from TheFile;
      is
         RawSize : Integer;
      begin

         Value := AuditTypes.FileSizeT'First;
         File.GetInteger(TheFile, RawSize, 0, Success);
         if Success and then
           (RawSize  <= Integer(AuditTypes.FileSizeT'Last)/2**10 and
            RawSize  >= Integer(AuditTypes.FileSizeT'First)/2**10) then
            Value := AuditTypes.FileSizeT(RawSize * 2**10);
         else
            Success := False;
         end if;

         if File.EndOfLine(TheFile) then
            File.SkipLine(TheFile, 1);
         else
            Success := False;
         end if;

      end ReadFileSize;

      ------------------------------------------------------------------
      -- ReadClass
      --
      -- Description:
      --      Reads a Class from file.
      --
      -- Implementation Notes:
      --      None.
      ------------------------------------------------------------------
      procedure ReadClass( Value : out PrivTypes.ClassT)
        --# global in out TheFile;
        --#           out Success;
        --# derives TheFile,
        --#         Value,
        --#         Success from TheFile;
      is
         RawClass : ClassTextT;
         Stop : Natural;
         Matched : Boolean := False;
      begin
         Value := PrivTypes.ClassT'First;
         File.GetLine(TheFile, RawClass, Stop);
         for C in PrivTypes.ClassT loop

            --# assert C in PrivTypes.ClassT;

            if Stop = ClassStringLookUp(C).Length then

               --# assert Stop in ClassTextI and
               --#        C in PrivTypes.ClassT;

               -- could be the correct text

               Matched := True;
               for I in ClassTextI range 1 .. Stop loop

                  --# assert Stop in ClassTextI and
                  --#        Stop = Stop% and
                  --#        I in ClassTextI and
                  --#        C in PrivTypes.ClassT and
                  --#        I <= Stop;

                  if ClassStringLookUp(C).Text(I) /= RawClass(I) then
                     Matched := False;
                     exit;
                  end if;
               end loop;
            end if;
            if Matched then
               Value := C;
               exit;
            end if;
         end loop;

         Success := Matched;

      end ReadClass;

      ------------------------------------------------------------------
      -- ReadWorkingHours
      --
      -- Description:
      --      Reads a working hour from file expect format hh:mm.
      --
      -- Implementation Notes:
      --     Working hours is held internally as a duration in 1/10 secs.
      ------------------------------------------------------------------
      procedure ReadWorkingHours( TheDuration : out Clock.DurationT)
        --# global in out TheFile;
        --#           out Success;
        --# derives TheFile,
        --#         Success,
        --#         TheDuration from TheFile;
      is
         RawHours : Integer;
         RawMinutes : Integer;
         Char : Character;

      begin

         TheDuration := Clock.DurationT'First;
         File.GetInteger(TheFile, RawHours, 2,Success);
         if Success and
           RawHours >= Integer(Clock.HoursT'First) and
           RawHours <= Integer(Clock.HoursT'Last) then
            File.GetChar(TheFile, Char);
            File.GetInteger(TheFile, RawMinutes, 2, Success);
            if Success and Char = ':' and
              RawMinutes >= Integer(Clock.MinutesT'First) and
              RawMinutes <= Integer(Clock.MinutesT'Last) then
               TheDuration := 600 *
                 (Clock.DurationT(RawHours) * 60 + Clock.DurationT(RawMinutes));
            end if;
         end if;

         if File.EndOfLine(TheFile) then
            File.SkipLine(TheFile, 1);
         else
            Success := False;
         end if;
      end ReadWorkingHours;


      ------------------------------------------------------------------
      -- ReadFar
      --
      -- Description:
      --      Reads a Far from file.
      --
      -- Implementation Notes:
      --      None.
      ------------------------------------------------------------------
      procedure ReadFar( Value : out IandATypes.FarT)
        --# global in out TheFile;
        --#           out Success;
        --# derives TheFile,
        --#         Value,
        --#         Success from TheFile;
      is
         RawFar : Integer;
      begin

         Value := IandATypes.FarT'First;
         File.GetInteger(TheFile, RawFar, 0, Success);
         if Success and then
           (RawFar <= Integer(IandATypes.FarT'Last) and
            RawFar >= Integer(IandATypes.FarT'First)) then
            Value := IandATypes.FarT(RawFar);
         else
            Success := False;
         end if;

         if File.EndOfLine(TheFile) then
            File.SkipLine(TheFile, 1);
         else
            Success := False;
         end if;

      end ReadFar;


      ------------------------------------------------------------------
      -- ReadAlarmSilent
      --
      -- Description:
      --      Reads the alarm silent value from file.
      --
      -- Implementation Notes:
      --      None.
      ------------------------------------------------------------------
      procedure ReadAlarmSilent
        --# global in out TheFile;
        --#           out Success;
        --#           out TheAlarmSilentDuration;
        --# derives TheFile,
        --#         Success,
        --#         TheAlarmSilentDuration from TheFile;
      is
         TheTitle : AlarmSilentTextT;
         Stop : Natural;
      begin

         TheAlarmSilentDuration := DurationT'First;
         File.GetString(TheFile, TheTitle, Stop);
         if Stop = TheTitle'Last and then
           TheTitle = AlarmSilentTitle then
            ReadDuration(TheAlarmSilentDuration);
         else
            Success := False;
         end if;

      end ReadAlarmSilent;

      ------------------------------------------------------------------
      -- ReadLatchUnlock
      --
      -- Description:
      --      Reads the latch unlock value from file.
      --
      -- Implementation Notes:
      --      None.
      ------------------------------------------------------------------
      procedure ReadLatchUnlock
        --# global in out TheFile;
        --#           out Success;
        --#           out TheLatchUnlockDuration;
        --# derives TheFile,
        --#         Success,
        --#         TheLatchUnlockDuration from TheFile;
      is
         TheTitle : LatchUnlockTextT;
         Stop : Natural;
      begin

         TheLatchUnlockDuration := DurationT'First;
         File.GetString(TheFile, TheTitle, Stop);
         if Stop = TheTitle'Last and then
           TheTitle = LatchUnlockTitle then
            ReadDuration(TheLatchUnlockDuration);
         else
            Success := False;
         end if;

      end ReadLatchUnlock;

      ------------------------------------------------------------------
      -- ReadFingerWait
      --
      -- Description:
      --      Reads the finger wait value from file.
      --
      -- Implementation Notes:
      --      None.
      ------------------------------------------------------------------
      procedure ReadFingerWait
        --# global in out TheFile;
        --#           out Success;
        --#           out TheFingerWaitDuration;
        --# derives TheFile,
        --#         Success,
        --#         TheFingerWaitDuration from TheFile;
      is
         TheTitle : FingerWaitTextT;
         Stop : Natural;
      begin

         TheFingerWaitDuration := DurationT'First;
         File.GetString(TheFile, TheTitle, Stop);
         if Stop = TheTitle'Last and then
           TheTitle = FingerWaitTitle then
            ReadDuration(TheFingerWaitDuration);
         else
            Success := False;
         end if;

      end ReadFingerWait;

      ------------------------------------------------------------------
      -- ReadTokenRemoval
      --
      -- Description:
      --      Reads the token removal value from file.
      --
      -- Implementation Notes:
      --      None.
      ------------------------------------------------------------------
      procedure ReadTokenRemoval
        --# global in out TheFile;
        --#           out Success;
        --#           out TheTokenRemovalDuration;
        --# derives TheFile,
        --#         Success,
        --#         TheTokenRemovalDuration from TheFile;
      is
         TheTitle : TokenRemovalTextT;
         Stop : Natural;
      begin

         TheTokenRemovalDuration := DurationT'First;
         File.GetString(TheFile, TheTitle, Stop);
         if Stop = TheTitle'Last and then
           TheTitle = TokenRemovalTitle then
            ReadDuration(TheTokenRemovalDuration);
         else
            Success := False;
         end if;

      end ReadTokenRemoval;

      ------------------------------------------------------------------
      -- ReadClearance
      --
      -- Description:
      --      Reads the enclave clearance value from file.
      --
      -- Implementation Notes:
      --      None.
      ------------------------------------------------------------------
      procedure ReadClearance
        --# global in out TheFile;
        --#           out Success;
        --#           out TheEnclaveClearance;
        --# derives TheFile,
        --#         Success,
        --#         TheEnclaveClearance from TheFile;
      is
         TheTitle : ClearanceTextT;
         Stop : Natural;
      begin

         TheEnclaveClearance := PrivTypes.ClassT'First;
         File.GetString(TheFile, TheTitle, Stop);
         if Stop = TheTitle'Last and then
           TheTitle = ClearanceTitle then
            ReadClass(TheEnclaveClearance);
         else
            Success := False;
         end if;

      end ReadClearance;

      ------------------------------------------------------------------
      -- ReadWorkingStart
      --
      -- Description:
      --      Reads the working hours start value from file.
      --
      -- Implementation Notes:
      --      None.
      ------------------------------------------------------------------
      procedure ReadWorkingStart
        --# global in out TheFile;
        --#           out Success;
        --#           out TheWorkingHoursStart;
        --# derives TheFile,
        --#         Success,
        --#         TheWorkingHoursStart from TheFile;
      is
         TheTitle : WorkingStartTextT;
         Stop : Natural;
      begin

         TheWorkingHoursStart := Clock.DurationT'First;
         File.GetString(TheFile, TheTitle, Stop);
         if Stop = TheTitle'Last and then
           TheTitle = WorkingStartTitle then
            ReadWorkingHours(TheWorkingHoursStart);
         else
            Success := False;
         end if;

      end ReadWorkingStart;

      ------------------------------------------------------------------
      -- ReadWorkingEnd
      --
      -- Description:
      --      Reads the working hours end value from file.
      --
      -- Implementation Notes:
      --      None.
      ------------------------------------------------------------------
      procedure ReadWorkingEnd
        --# global in out TheFile;
        --#           out Success;
        --#           out TheWorkingHoursEnd;
        --# derives TheFile,
        --#         Success,
        --#         TheWorkingHoursEnd from TheFile;
      is
         TheTitle : WorkingEndTextT;
         Stop : Natural;
      begin

         TheWorkingHoursEnd := Clock.DurationT'First;
         File.GetString(TheFile, TheTitle, Stop);
         if Stop = TheTitle'Last and then
           TheTitle = WorkingEndTitle then
            ReadWorkingHours(TheWorkingHoursEnd);
         else
            Success := False;
         end if;

      end ReadWorkingEnd;

      ------------------------------------------------------------------
      -- ReadAuthDuration
      --
      -- Description:
      --      Reads the max auth duration value from file.
      --
      -- Implementation Notes:
      --      None.
      ------------------------------------------------------------------
      procedure ReadAuthDuration
        --# global in out TheFile;
        --#           out Success;
        --#           out TheMaxAuthDuration;
        --# derives TheFile,
        --#         Success,
        --#         TheMaxAuthDuration from TheFile;
      is
         TheTitle : MaxAuthDurationTextT;
         Stop : Natural;
      begin

         TheMaxAuthDuration := Clock.DurationT'First;
         File.GetString(TheFile, TheTitle, Stop);
         if Stop = TheTitle'Last and then
           TheTitle = MaxAuthDurationTitle then
            ReadWorkingHours(TheMaxAuthDuration);
         else
            Success := False;
         end if;

      end ReadAuthDuration;

      ------------------------------------------------------------------
      -- ReadAccessPolicy
      --
      -- Description:
      --      Reads the access policy value from file.
      --
      -- Implementation Notes:
      --      None.
      ------------------------------------------------------------------
      procedure ReadAccessPolicy
        --# global in out TheFile;
        --#           out Success;
        --#           out TheAccessPolicy;
        --# derives TheFile,
        --#         Success,
        --#         TheAccessPolicy from TheFile;
      is
         TheTitle : AccessPolicyTextT;
         RawAccessPolicy : AccessTextT;
         Stop : Natural;
         Matched : Boolean := False;
      begin

         TheAccessPolicy := AccessPolicyT'First;
         File.GetString(TheFile, TheTitle, Stop);
         if Stop = TheTitle'Last and then
           TheTitle = AccessPolicyTitle then

            File.GetLine(TheFile, RawAccessPolicy, Stop);
            for AP in AccessPolicyT loop
               --# assert AP in AccessPolicyT;
               if Stop = AccessStringLookUp(AP).Length then
                  --# assert AP in AccessPolicyT and
                  --#        Stop in AccessTextI;

                  -- could be the correct text
                  Matched := True;
                  for I in AccessTextI range 1 .. Stop loop
                     --# assert AP in AccessPolicyT and
                     --#        Stop in AccessTextI and
                     --#        Stop = Stop% and
                     --#        I in AccessTextI and
                     --#        I <= Stop;
                     if AccessStringLookUp(AP).Text(I) /= RawAccessPolicy(I) then
                        Matched := False;
                        exit;
                     end if;
                  end loop;
               end if;
               if Matched then
                  TheAccessPolicy := AP;
                  exit;
               end if;
            end loop;

            Success := Matched;

         else
            Success := False;
         end if;

      end ReadAccessPolicy;

      ------------------------------------------------------------------
      -- ReadMinEntryClass
      --
      -- Description:
      --      Reads the min entry class value from file.
      --
      -- Implementation Notes:
      --      None.
      ------------------------------------------------------------------
      procedure ReadMinEntryClass
        --# global in out TheFile;
        --#           out Success;
        --#           out TheMinEntryClass;
        --# derives TheFile,
        --#         Success,
        --#         TheMinEntryClass from TheFile;
      is
         TheTitle : MinEntryClassTextT;
         Stop : Natural;
      begin

         TheMinEntryClass := PrivTypes.ClassT'First;
         File.GetString(TheFile, TheTitle, Stop);
         if Stop = TheTitle'Last and then
           TheTitle = MinEntryClassTitle then
            ReadClass(TheMinEntryClass);
         else
            Success := False;
         end if;

      end ReadMinEntryClass;

      ------------------------------------------------------------------
      -- ReadMinPreservedLog
      --
      -- Description:
      --      Reads the min preserved log size value from file.
      --
      -- Implementation Notes:
      --      None.
      ------------------------------------------------------------------
      procedure ReadMinPreservedLog
        --# global in out TheFile;
        --#           out Success;
        --#           out TheMinPreservedLogSize;
        --# derives TheFile,
        --#         Success,
        --#         TheMinPreservedLogSize from TheFile;
      is
         TheTitle : MinPreservedLogSizeTextT;
         Stop : Natural;
      begin

         TheMinPreservedLogSize := AuditTypes.FileSizeT'First;
         File.GetString(TheFile, TheTitle, Stop);
         if Stop = TheTitle'Last and then
           TheTitle = MinPreservedLogSizeTitle then
            ReadFileSize(TheMinPreservedLogSize);
         else
            Success := False;
         end if;

      end ReadMinPreservedLog;

      ------------------------------------------------------------------
      -- ReadAlarmThreshold
      --
      -- Description:
      --      Reads the log alarm threshold value from file.
      --
      -- Implementation Notes:
      --      None.
      ------------------------------------------------------------------
      procedure ReadAlarmThreshold
        --# global in out TheFile;
        --#           out Success;
        --#           out TheAlarmThresholdSize;
        --# derives TheFile,
        --#         Success,
        --#         TheAlarmThresholdSize from TheFile;
      is
         TheTitle : AlarmThresholdTextT;
         Stop : Natural;
      begin

         TheAlarmThresholdSize := AuditTypes.FileSizeT'First;
         File.GetString(TheFile, TheTitle, Stop);
         if Stop = TheTitle'Last and then
           TheTitle = AlarmThresholdTitle then
            ReadFileSize(TheAlarmThresholdSize);
         else
            Success := False;
         end if;

      end ReadAlarmThreshold;


      ------------------------------------------------------------------
      -- ReadSystemMaxFar
      --
      -- Description:
      --      Reads the system max FAR from file.
      --
      -- Implementation Notes:
      --      None.
      ------------------------------------------------------------------
      procedure ReadSystemMaxFar
        --# global in out TheFile;
        --#           out Success;
        --#           out TheSystemMaxFar;
        --# derives TheFile,
        --#         Success,
        --#         TheSystemMaxFar from TheFile;
      is
         TheTitle : SystemMaxFarTextT;
         Stop : Natural;
      begin

         TheSystemMaxFar := IandATypes.FarT'First;
         File.GetString(TheFile, TheTitle, Stop);
         if Stop = TheTitle'Last and then
           TheTitle = SystemMaxFarTitle then
            ReadFar(TheSystemMaxFar);
         else
            Success := False;
         end if;

      end ReadSystemMaxFar;



   ---------------------------------------------------------------
   -- begin ValidateFile
   ---------------------------------------------------------------
   begin


      File.OpenRead (TheFile => TheFile,
                     Success => Success);
      if Success then
         ReadAlarmSilent;
      else
         TheAlarmSilentDuration := DurationT'First;
      end if;

      --# assert True;

      if Success then
         ReadLatchUnlock;
      else
         TheLatchUnlockDuration  := DurationT'First;
      end if;

      --# assert True;

      if Success then
         ReadTokenRemoval;
      else
         TheTokenRemovalDuration  := DurationT'First;
      end if;

      --# assert True;

      if Success then
         ReadFingerWait;
      else
         TheFingerWaitDuration  := DurationT'First;
      end if;

      if Success then
         ReadClearance;
      else
         TheEnclaveClearance     := PrivTypes.ClassT'First;
      end if;

      --# assert True;

      if Success then
         ReadWorkingStart;
      else
         TheWorkingHoursStart    := Clock.DurationT'First;
      end if;

      --# assert True;

      if Success then
         ReadWorkingEnd;
      else
         TheWorkingHoursEnd    := Clock.DurationT'First;
      end if;

      --# assert True;

      if Success then
         ReadAuthDuration;
      else
         TheMaxAuthDuration    := Clock.DurationT'First;
      end if;

      --# assert True;

      if Success then
         ReadAccessPolicy;
      else
         TheAccessPolicy   := AccessPolicyT'First;
      end if;

      --# assert True;

      if Success then
         ReadMinEntryClass;
      else
         TheMinEntryClass   := PrivTypes.ClassT'First;
      end if;

      --# assert True;

      if Success then
         ReadMinPreservedLog;
      else
         TheMinPreservedLogSize  := AuditTypes.FileSizeT'First;
      end if;

      --# assert True;

      if Success then
         ReadAlarmThreshold;
      else
         TheAlarmThresholdSize  := AuditTypes.FileSizeT'First;
      end if;

      --# assert True;

      if Success then
         ReadSystemMaxFar;
      else
         TheSystemMaxFar  := IandATypes.FarT'First;
      end if;

      File.Close(TheFile => TheFile,
                 Success => OK);

      Success := Success and OK;

      if Success then
         -- check the added constraints on values.
         Success := (TheMinPreservedLogSize >= TheAlarmThresholdSize)
                     and (TheEnclaveClearance >= TheMinEntryClass);
      end if;

   end ValidateFile;

   ------------------------------------------------------------------
   -- WriteFile
   --
   -- Implementation Notes:
   --      None.
   --
   ------------------------------------------------------------------
   procedure WriteFile
     (Success                 :    out Boolean;
      TheLatchUnlockDuration  : in     DurationT;
      TheAlarmSilentDuration  : in     DurationT;
      TheFingerWaitDuration   : in     DurationT;
      TheTokenRemovalDuration : in     DurationT;
      TheEnclaveClearance     : in     PrivTypes.ClassT;
      TheWorkingHoursStart    : in     Clock.DurationT;
      TheWorkingHoursEnd      : in     Clock.DurationT;
      TheMaxAuthDuration      : in     Clock.DurationT;
      TheAccessPolicy         : in     AccessPolicyT;
      TheMinEntryClass        : in     PrivTypes.ClassT;
      TheMinPreservedLogSize  : in     AuditTypes.FileSizeT;
      TheAlarmThresholdSize   : in     AuditTypes.FileSizeT;
      TheSystemMaxFar         : in     IandATypes.FarT
      )
   --# global in out ConfigFile;
   --# derives Success,
   --#         ConfigFile from ConfigFile,
   --#                         TheAlarmSilentDuration,
   --#                         TheLatchUnlockDuration,
   --#                         TheFingerWaitDuration,
   --#                         TheTokenRemovalDuration,
   --#                         TheEnclaveClearance,
   --#                         TheWorkingHoursStart,
   --#                         TheWorkingHoursEnd,
   --#                         TheMaxAuthDuration,
   --#                         TheAccessPolicy,
   --#                         TheMinEntryClass,
   --#                         TheMinPreservedLogSize,
   --#                         TheAlarmThresholdSize,
   --#                         TheSystemMaxFar;
   is
      CloseOK : Boolean;

      subtype String5I is Positive range 1 .. 5;
      subtype String5T is String(String5I);

      ------------------------------------------------------------------
      -- WorkingHoursText
      --
      -- Description:
      --      converts a duration (1/10 sec) to HH:MM text string.
      --
      -- Implementation Notes:
      --      None.
      ------------------------------------------------------------------
      function WorkingHoursText (Value : Clock.DurationT) return String5T
      is
         LocalText : String5T := "00:00";
         LocalValue : Clock.DurationT;
      begin

         -- extract the hours
         LocalValue := Value / 36000;

         LocalText(1) := Character'Val(Character'Pos('0') + LocalValue / 10);
         LocalText(2) := Character'Val(Character'Pos('0') + LocalValue mod 10);

         -- extract the minutes
         LocalValue := (Value mod 36000) / 600;
         LocalText(4) := Character'Val(Character'Pos('0') + LocalValue / 10);
         LocalText(5) := Character'Val(Character'Pos('0') + LocalValue mod 10);

         return LocalText;
      end WorkingHoursText;

   begin

      if File.Exists (ConfigFile) then
          File.OpenWrite (TheFile => ConfigFile,
                          Success => Success);
      else
         File.Create (TheFile => ConfigFile,
                      Success => Success);
      end if;

      --# assert True;

      if Success then

         -- write AlarmSilentDuration (convert from 1/10s to secs)
         File.PutString(TheFile => ConfigFile,
                        Text    => AlarmSilentTitle,
                        Stop    => 0);
         File.PutInteger(TheFile => ConfigFile,
                         Item    => Integer(TheAlarmSilentDuration) / 10,
                         Width    => 0);
         File.NewLine(TheFile   => ConfigFile,
                      Spacing   => 1);

         -- write LatchUnlockDuration (convert from 1/10s to secs)
         File.PutString(TheFile => ConfigFile,
                        Text    => LatchUnlockTitle,
                        Stop    => 0);
         File.PutInteger(TheFile => ConfigFile,
                         Item    => Integer(TheLatchUnlockDuration) / 10,
                         Width    => 0);
         File.NewLine(TheFile   => ConfigFile,
                      Spacing   => 1);

         -- write TokenRemovalDuration (convert from 1/10s to secs)
         File.PutString(TheFile => ConfigFile,
                        Text    => TokenRemovalTitle,
                        Stop    => 0);
         File.PutInteger(TheFile => ConfigFile,
                         Item    => Integer(TheTokenRemovalDuration) / 10,
                         Width    => 0);
         File.NewLine(TheFile   => ConfigFile,
                      Spacing   => 1);

         -- write FingerWaitDuration (convert from 1/10s to secs)
         File.PutString(TheFile => ConfigFile,
                        Text    => FingerWaitTitle,
                        Stop    => 0);
         File.PutInteger(TheFile => ConfigFile,
                         Item    => Integer(TheFingerWaitDuration) / 10,
                         Width    => 0);
         File.NewLine(TheFile   => ConfigFile,
                      Spacing   => 1);

         -- write Clearance
         File.PutString(TheFile => ConfigFile,
                        Text    => ClearanceTitle,
                        Stop    => 0);
         File.PutString(TheFile => ConfigFile,
                        Text    => ClassStringLookup(TheEnclaveClearance).Text,
                        Stop    => ClassStringLookup(TheEnclaveClearance).Length);
         File.NewLine(TheFile   => ConfigFile,
                      Spacing   => 1);

         -- write WorkingStart (convert from 1/10 sec to HH:MM)
         File.PutString(TheFile => ConfigFile,
                        Text    => WorkingStartTitle,
                        Stop    => 0);
         File.PutString(TheFile => ConfigFile,
                        Text    => WorkingHoursText(TheWorkingHoursStart),
                        Stop    => 0);
         File.NewLine(TheFile   => ConfigFile,
                      Spacing   => 1);

         -- write WorkingEnd (convert from 1/10 sec to HH:MM)
         File.PutString(TheFile => ConfigFile,
                        Text    => WorkingEndTitle,
                        Stop    => 0);
         File.PutString(TheFile => ConfigFile,
                        Text    => WorkingHoursText(TheWorkingHoursEnd),
                        Stop    => 0);
         File.NewLine(TheFile   => ConfigFile,
                      Spacing   => 1);

         -- write MaxAuthDuration (convert from 1/10 sec to HH:MM)
         File.PutString(TheFile => ConfigFile,
                        Text    => MaxAuthDurationTitle,
                        Stop    => 0);
         File.PutString(TheFile => ConfigFile,
                        Text    => WorkingHoursText(TheMaxAuthDuration),
                        Stop    => 0);
         File.NewLine(TheFile   => ConfigFile,
                      Spacing   => 1);

         -- write AccessPolicy
         File.PutString(TheFile => ConfigFile,
                        Text    => AccessPolicyTitle,
                        Stop    => 0);
         File.PutString(TheFile => ConfigFile,
                        Text    => AccessStringLookup(TheAccessPolicy).Text,
                        Stop    => AccessStringLookup(TheAccessPolicy).Length);
         File.NewLine(TheFile   => ConfigFile,
                      Spacing   => 1);

         -- write MinEntryClass
         File.PutString(TheFile => ConfigFile,
                        Text    => MinEntryClassTitle,
                        Stop    => 0);
         File.PutString(TheFile => ConfigFile,
                        Text    => ClassStringLookup(TheMinEntryClass).Text,
                        Stop    => ClassStringLookup(TheMinEntryClass).Length);
         File.NewLine(TheFile   => ConfigFile,
                      Spacing   => 1);

         -- write MinPreservedLogSize (convert from Bytes to KBytes)
         File.PutString(TheFile => ConfigFile,
                        Text    => MinPreservedLogSizeTitle,
                        Stop    => 0);
         File.PutInteger(TheFile => ConfigFile,
                         Item    => Integer(TheMinPreservedLogSize) / 2**10,
                         Width    => 0);
         File.NewLine(TheFile   => ConfigFile,
                      Spacing   => 1);

         -- write AlarmThreshold (convert from Bytes to KBytes)
         File.PutString(TheFile => ConfigFile,
                        Text    => AlarmThresholdTitle,
                        Stop    => 0);
         File.PutInteger(TheFile => ConfigFile,
                         Item    => Integer(TheAlarmThresholdSize) / 2**10,
                         Width    => 0);
         File.NewLine(TheFile   => ConfigFile,
                      Spacing   => 1);


         -- write SystemMaxFar
         File.PutString(TheFile => ConfigFile,
                        Text    => SystemMaxFarTitle,
                        Stop    => 0);
         File.PutInteger(TheFile => ConfigFile,
                         Item    => Integer(TheSystemMaxFar),
                         Width    => 0);
         File.NewLine(TheFile   => ConfigFile,
                      Spacing   => 1);

      end if;

      File.Close(TheFile => ConfigFile,
                 Success => CloseOK);

      Success := CloseOK and Success;

   end WriteFile;

   ------------------------------------------------------------------
   -- Init
   --
   -- Implementation Notes:
   --        None.
   ------------------------------------------------------------------
   procedure Init
   --# global in out ConfigFile;
   --#           out LatchUnlockDuration;
   --#           out AlarmSilentDuration;
   --#           out FingerWaitDuration;
   --#           out TokenRemovalDuration;
   --#           out EnclaveClearance;
   --#           out WorkingHoursStart;
   --#           out WorkingHoursEnd;
   --#           out MaxAuthDuration;
   --#           out AccessPolicy;
   --#           out MinEntryClass;
   --#           out MinPreservedLogSize;
   --#           out AlarmThresholdSize;
   --#           out SystemMaxFar;
   --# derives ConfigFile,
   --#         LatchUnlockDuration,
   --#         AlarmSilentDuration,
   --#         FingerWaitDuration,
   --#         TokenRemovalDuration,
   --#         EnclaveClearance,
   --#         WorkingHoursStart,
   --#         WorkingHoursEnd,
   --#         MaxAuthDuration,
   --#         AccessPolicy,
   --#         MinEntryClass,
   --#         MinPreservedLogSize,
   --#         AlarmThresholdSize,
   --#         SystemMaxFar         from ConfigFile;
   is

      OK, Unused : Boolean;
      LocalLatchUnlockDuration  : DurationT;
      LocalAlarmSilentDuration  : DurationT;
      LocalFingerWaitDuration   : DurationT;
      LocalTokenRemovalDuration : DurationT;
      LocalEnclaveClearance     : PrivTypes.ClassT;
      LocalWorkingHoursStart    : Clock.DurationT;
      LocalWorkingHoursEnd      : Clock.DurationT;
      LocalMaxAuthDuration      : Clock.DurationT;
      LocalAccessPolicy         : AccessPolicyT;
      LocalMinEntryClass        : PrivTypes.ClassT;
      LocalMinPreservedLogSize  : AuditTypes.FileSizeT;
      LocalAlarmThresholdSize   : AuditTypes.FileSizeT;
      LocalSystemMaxFar         : IandATypes.FarT;

   ------------------------------------------------------------------
   -- SetDefaults
   --
   -- Description:
   --      Initialises the configuration data to default values.
   --
   -- Implementation Notes:
   --    None.
   --
   ------------------------------------------------------------------
      procedure SetDefaults
   --# global out LatchUnlockDuration;
   --#        out AlarmSilentDuration;
   --#        out FingerWaitDuration;
   --#        out TokenRemovalDuration;
   --#        out EnclaveClearance;
   --#        out WorkingHoursStart;
   --#        out WorkingHoursEnd;
   --#        out MaxAuthDuration;
   --#        out AccessPolicy;
   --#        out MinEntryClass;
   --#        out MinPreservedLogSize;
   --#        out AlarmThresholdSize;
   --#        out SystemMaxFar;
   --# derives LatchUnlockDuration,
   --#         AlarmSilentDuration,
   --#         FingerWaitDuration,
   --#         TokenRemovalDuration,
   --#         EnclaveClearance,
   --#         WorkingHoursStart,
   --#         WorkingHoursEnd,
   --#         MaxAuthDuration,
   --#         AccessPolicy,
   --#         MinEntryClass,
   --#         MinPreservedLogSize,
   --#         AlarmThresholdSize,
   --#         SystemMaxFar         from ;
   is
   begin

      LatchUnlockDuration  := 150;
      AlarmSilentDuration  := 10;
      FingerWaitDuration   := 100;
      TokenRemovalDuration := 100;
      EnclaveClearance     := PrivTypes.Unmarked;
      WorkingHoursStart    := 3600;
      WorkingHoursEnd      := 0;
      MaxAuthDuration      := 72000;
      AccessPolicy         := AllHours;
      MinEntryClass        := PrivTypes.Unmarked;
      MinPreservedLogSize  := 1024 * AuditTypes.SizeAuditElement;
      AlarmThresholdSize   := 100 * AuditTypes.SizeAuditElement;
      SystemMaxFar         := 1000;

   end SetDefaults;


   ----------------------------------------------------------------------
   -- begin Init
   ----------------------------------------------------------------------
   begin
      File.SetName( TheFile => ConfigFile,
                    TheName => "./System/config.dat");

      File.CreateDirectory( DirName => "System",
                            Success => OK);

      if OK and File.Exists (ConfigFile) then
         ValidateFile
           (TheFile                 => ConfigFile,
            Success                 => OK,
            TheLatchUnlockDuration  => LocalLatchUnlockDuration,
            TheAlarmSilentDuration  => LocalAlarmSilentDuration,
            TheFingerWaitDuration   => LocalFingerWaitDuration,
            TheTokenRemovalDuration => LocalTokenRemovalDuration,
            TheEnclaveClearance     => LocalEnclaveClearance,
            TheWorkingHoursStart    => LocalWorkingHoursStart,
            TheWorkingHoursEnd      => LocalWorkingHoursEnd,
            TheMaxAuthDuration      => LocalMaxAuthDuration,
            TheAccessPolicy         => LocalAccessPolicy,
            TheMinEntryClass        => LocalMinEntryClass,
            TheMinPreservedLogSize  => LocalMinPreservedLogSize,
            TheAlarmThresholdSize   => LocalAlarmThresholdSize,
            TheSystemMaxFar         => LocalSystemMaxFar);
         if OK then
            -- Set local values;
            LatchUnlockDuration  := LocalLatchUnlockDuration;
            AlarmSilentDuration  := LocalAlarmSilentDuration;
            FingerWaitDuration   := LocalFingerWaitDuration;
            TokenRemovalDuration := LocalTokenRemovalDuration;
            EnclaveClearance     := LocalEnclaveClearance;
            WorkingHoursStart    := LocalWorkingHoursStart;
            WorkingHoursEnd      := LocalWorkingHoursEnd;
            MaxAuthDuration      := LocalMaxAuthDuration;
            AccessPolicy         := LocalAccessPolicy;
            MinEntryClass        := LocalMinEntryClass;
            MinPreservedLogSize  := LocalMinPreservedLogSize;
            AlarmThresholdSize   := LocalAlarmThresholdSize;
            SystemMaxFar         := LocalSystemMaxFar;

         else

            -- Set to default values;
            SetDefaults;
            -- Delete the faulty file.

            --# accept F, 10, Unused, "Ineffective assignment expected here" &
            --#        F, 33, Unused, "Ineffective assignment expected here";
            File.OpenRead (ConfigFile, Unused);
            File.Delete (ConfigFile, Unused);
         end if;

      else
         SetDefaults;

      end if;

   end Init;



   ------------------------------------------------------------------
   -- UpdateData
   --
   -- Implementation Notes:
   --    None.
   --
   ------------------------------------------------------------------
   procedure UpdateData
     (TheLatchUnlockDuration  : in     DurationT;
      TheAlarmSilentDuration  : in     DurationT;
      TheFingerWaitDuration   : in     DurationT;
      TheTokenRemovalDuration : in     DurationT;
      TheEnclaveClearance     : in     PrivTypes.ClassT;
      TheWorkingHoursStart    : in     Clock.DurationT;
      TheWorkingHoursEnd      : in     Clock.DurationT;
      TheMaxAuthDuration      : in     Clock.DurationT;
      TheAccessPolicy         : in     AccessPolicyT;
      TheMinEntryClass        : in     PrivTypes.ClassT;
      TheMinPreservedLogSize  : in     AuditTypes.FileSizeT;
      TheAlarmThresholdSize   : in     AuditTypes.FileSizeT;
      TheSystemMaxFar         : in     IandATypes.FarT
      )
   --# global out LatchUnlockDuration;
   --#        out AlarmSilentDuration;
   --#        out FingerWaitDuration;
   --#        out TokenRemovalDuration;
   --#        out EnclaveClearance;
   --#        out WorkingHoursStart;
   --#        out WorkingHoursEnd;
   --#        out MaxAuthDuration;
   --#        out AccessPolicy;
   --#        out MinEntryClass;
   --#        out MinPreservedLogSize;
   --#        out AlarmThresholdSize;
   --#        out SystemMaxFar;
   --# derives LatchUnlockDuration  from TheLatchUnlockDuration &
   --#         AlarmSilentDuration  from TheAlarmSilentDuration &
   --#         FingerWaitDuration   from TheFingerWaitDuration &
   --#         TokenRemovalDuration from TheTokenRemovalDuration &
   --#         EnclaveClearance     from TheEnclaveClearance &
   --#         WorkingHoursStart    from TheWorkingHoursStart &
   --#         WorkingHoursEnd      from TheWorkingHoursEnd &
   --#         MaxAuthDuration      from TheMaxAuthDuration &
   --#         AccessPolicy         from TheAccessPolicy &
   --#         MinEntryClass        from TheMinEntryClass &
   --#         MinPreservedLogSize  from TheMinPreservedLogSize &
   --#         AlarmThresholdSize   from TheAlarmThresholdSize &
   --#         SystemMaxFar         from TheSystemMaxFar;
   is
   begin
       LatchUnlockDuration  := TheLatchUnlockDuration;
       AlarmSilentDuration  := TheAlarmSilentDuration;
       FingerWaitDuration   := TheFingerWaitDuration;
       TokenRemovalDuration := TheTokenRemovalDuration;
       EnclaveClearance     := TheEnclaveClearance;
       WorkingHoursStart    := TheWorkingHoursStart;
       WorkingHoursEnd      := TheWorkingHoursEnd;
       MaxAuthDuration      := TheMaxAuthDuration;
       AccessPolicy         := TheAccessPolicy;
       MinEntryClass        := TheMinEntryClass;
       MinPreservedLogSize  := TheMinPreservedLogSize;
       AlarmThresholdSize   := TheAlarmThresholdSize;
       SystemMaxFar         := TheSystemMaxFar;

   end UpdateData;
   ------------------------------------------------------------------
   -- TheDisplayFields
   --
   -- Implementation Notes:
   --    None.
   --
   ------------------------------------------------------------------
   procedure TheDisplayFields
     (TheLatchUnlockDuration  : out DurationT;
      TheAlarmSilentDuration  : out DurationT;
      TheFingerWaitDuration   : out DurationT;
      TheTokenRemovalDuration : out DurationT;
      TheEnclaveClearance     : out PrivTypes.ClassT;
      TheWorkingHoursStart    : out Clock.DurationT;
      TheWorkingHoursEnd      : out Clock.DurationT;
      TheMaxAuthDuration      : out Clock.DurationT;
      TheAccessPolicy         : out AccessPolicyT;
      TheMinEntryClass        : out PrivTypes.ClassT;
      TheMinPreservedLogSize  : out AuditTypes.FileSizeT;
      TheAlarmThresholdSize   : out AuditTypes.FileSizeT;
      TheSystemMaxFar         : out IandATypes.FarT
      )
   --# global in LatchUnlockDuration;
   --#        in AlarmSilentDuration;
   --#        in FingerWaitDuration;
   --#        in TokenRemovalDuration;
   --#        in EnclaveClearance;
   --#        in WorkingHoursStart;
   --#        in WorkingHoursEnd;
   --#        in MaxAuthDuration;
   --#        in AccessPolicy;
   --#        in MinEntryClass;
   --#        in MinPreservedLogSize;
   --#        in AlarmThresholdSize;
   --#        in SystemMaxFar;
   --# derives TheAlarmSilentDuration  from AlarmSilentDuration &
   --#         TheLatchUnlockDuration  from LatchUnlockDuration &
   --#         TheFingerWaitDuration   from FingerWaitDuration &
   --#         TheTokenRemovalDuration from TokenRemovalDuration &
   --#         TheEnclaveClearance     from EnclaveClearance &
   --#         TheWorkingHoursStart    from WorkingHoursStart &
   --#         TheWorkingHoursEnd      from WorkingHoursEnd &
   --#         TheMaxAuthDuration      from MaxAuthDuration &
   --#         TheAccessPolicy         from AccessPolicy &
   --#         TheMinEntryClass        from MinEntryClass &
   --#         TheMinPreservedLogSize  from MinPreservedLogSize &
   --#         TheAlarmThresholdSize   from AlarmThresholdSize &
   --#         TheSystemMaxFar         from SystemMaxFar;

   is
   begin
       TheLatchUnlockDuration  := LatchUnlockDuration;
       TheAlarmSilentDuration  := AlarmSilentDuration;
       TheFingerWaitDuration   := FingerWaitDuration;
       TheTokenRemovalDuration := TokenRemovalDuration;
       TheEnclaveClearance     := EnclaveClearance;
       TheWorkingHoursStart    := WorkingHoursStart;
       TheWorkingHoursEnd      := WorkingHoursEnd;
       TheMaxAuthDuration      := MaxAuthDuration;
       TheAccessPolicy         := AccessPolicy;
       TheMinEntryClass        := MinEntryClass;
       TheMinPreservedLogSize  := MinPreservedLogSize;
       TheAlarmThresholdSize   := AlarmThresholdSize;
       TheSystemMaxFar         := SystemMaxFar;

   end TheDisplayFields;

   ------------------------------------------------------------------
   -- AuthPeriodIsEmpty
   --
   -- Implementation Notes:
   --    None.
   --
   ------------------------------------------------------------------
   function AuthPeriodIsEmpty return Boolean
   --# global WorkingHoursStart,
   --#        WorkingHoursEnd,
   --#        MaxAuthDuration,
   --#        AccessPolicy;
   is
      Result : Boolean;

   begin

      if AccessPolicy = AllHours then
         if MaxAuthDuration > 0 then
            Result := False;
         else
            Result := True;
         end if;
      else  -- AccessPolicy = WorkingHours

         if WorkingHoursStart > WorkingHoursEnd then
            -- day start is after the end of the day.
            Result := True;
         else
            Result := False;
         end if;
      end if;

      return Result;
   end AuthPeriodIsEmpty;
   ------------------------------------------------------------------
   -- GetAuthPeriod
   --
   -- Implementation Notes:
   --    None.
   --
   ------------------------------------------------------------------
   procedure GetAuthPeriod
     ( TheTime   : in     Clock.TimeT;
       NotBefore :    out Clock.TimeT;
       NotAfter  :    out Clock.TimeT)
   --# global in WorkingHoursStart;
   --#        in WorkingHoursEnd;
   --#        in MaxAuthDuration;
   --#        in AccessPolicy;
   --# derives NotBefore from WorkingHoursStart,
   --#                        AccessPolicy,
   --#                        TheTime &
   --#         NotAfter  from WorkingHoursEnd,
   --#                        MaxAuthDuration,
   --#                        AccessPolicy,
   --#                        TheTime;
   is
      DayStart : Clock.TimeT;

   begin

      if AccessPolicy = AllHours then
         NotBefore := TheTime;
         if MaxAuthDuration > 0 then
            NotAfter := Clock.AddDuration (TheTime, (MaxAuthDuration - 1));
         else
            NotAfter := Clock.ZeroTime;
         end if;

      else  -- AccessPolicy = WorkingHours
         DayStart := Clock.StartOfDay (TheTime => TheTime);

         NotBefore := Clock.AddDuration (DayStart, WorkingHoursStart);
         NotAfter  := Clock.AddDuration (DayStart, WorkingHoursEnd);
      end if;
   end GetAuthPeriod;

   ------------------------------------------------------------------
   -- IsInEntryPeriod
   --
   -- Implementation Notes:
   --    None.
   --
   ------------------------------------------------------------------
   function IsInEntryPeriod
     ( Class : PrivTypes.ClassT;
       TheTime : Clock.TimeT) return Boolean
   --# global WorkingHoursStart,
   --#        WorkingHoursEnd,
   --#        AccessPolicy,
   --#        MinEntryClass;
   is
      Result : Boolean;
      DayStart : Clock.TimeT;

   begin
      if Class >= MinEntryClass then
         if AccessPolicy = AllHours then
            Result := True;
         else  -- AccessPolicy = WorkingHours
            DayStart := Clock.StartOfDay (TheTime => TheTime);

            if Clock.LessThan  -- Not in working day.
                 (TheTime,
                  Clock.AddDuration(DayStart, WorkingHoursStart))
              or Clock.GreaterThan
                 (TheTime,
                  Clock.AddDuration(DayStart, WorkingHoursEnd)) then
               Result := False;
            else
               Result := True;
            end if;
         end if;
      else    -- not Class >= MinEntryClass
         Result := False;
      end if;

      return Result;
   end IsInEntryPeriod;
   ------------------------------------------------------------------
   -- TheLatchUnlockDuration
   --
   -- Implementation Notes:
   --    None.
   --
   ------------------------------------------------------------------
   function TheLatchUnlockDuration return DurationT
   --# global LatchUnlockDuration;
   is
   begin
      return LatchUnlockDuration;
   end TheLatchUnlockDuration;
   ------------------------------------------------------------------
   -- TheAlarmSilentDuration
   --
   -- Implementation Notes:
   --    None.
   --
   ------------------------------------------------------------------
   function TheAlarmSilentDuration return DurationT
   --# global AlarmSilentDuration;
   is
   begin
      return AlarmSilentDuration;
   end TheAlarmSilentDuration;

   ------------------------------------------------------------------
   -- TheFingerWaitDuration
   --
   -- Implementation Notes:
   --    None.
   --
   ------------------------------------------------------------------
   function TheFingerWaitDuration return DurationT
   --# global FingerWaitDuration;
   is
   begin
      return FingerWaitDuration;
   end TheFingerWaitDuration;

   ------------------------------------------------------------------
   -- TheTokenRemovalDuration
   --
   -- Implementation Notes:
   --    None.
   --
   ------------------------------------------------------------------
   function TheTokenRemovalDuration return DurationT
   --# global TokenRemovalDuration;
   is
   begin
      return TokenRemovalDuration;
   end TheTokenRemovalDuration;

   ------------------------------------------------------------------
   -- TheEnclaveClearance
   --
   -- Implementation Notes:
   --    None.
   --
   ------------------------------------------------------------------
   function TheEnclaveClearance return PrivTypes.ClassT
   --# global EnclaveClearance;
   is
   begin
      return EnclaveClearance;
   end TheEnclaveClearance;

   ------------------------------------------------------------------
   -- TheSystemMaxFar
   --
   -- Implementation Notes:
   --    None.
   --
   ------------------------------------------------------------------
   function TheSystemMaxFar return IandATypes.FarT
   --# global SystemMaxFar;
   is
   begin
      return SystemMaxFar;
   end TheSystemMaxFar;

   ------------------------------------------------------------------
   -- TheAlarmThresholdEntries
   --
   -- Implementation Notes:
   --    To ensure that alarm is raised when we EXCEED the AlarmThresholdSize
   --    round up the number of entries.
   --    From the Design:
   --    alarmThresholdEntries * sizeAuditElement >= alarmThresholdSize
   --    (alarmThresholdEntries -1) * sizeAuditElement < alarmThresholdSize
   --    Hence
   --    alarmThresholdEntries >= alarmThresholdSize/sizeAuditElement
   --    alarmThresholdEntries <
   --             (alarmThresholdSize + sizeAuditElement)/sizeAuditElement
   --    Setting
   --    alarmThresholdEntries =
   --         (alarmThresholdSize + sizeAuditElement -1) div sizeAuditElement
   --    always gives the next integer >= alarmThresholdSize/sizeAuditElement
   ------------------------------------------------------------------
   function TheAlarmThresholdEntries return AuditTypes.AuditEntryCountT
   --# global AlarmThresholdSize;
   is
      LocalSize : AuditTypes.AuditEntryCountT;
   begin
      if AuditTypes.FileSizeT'Last - AlarmThresholdSize <
        AuditTypes.FileSizeT'(AuditTypes.SizeAuditElement) - 1 then
         LocalSize := AuditTypes.AuditEntryCountT'Last;
      else
         LocalSize := AuditTypes.AuditEntryCountT
          (((AlarmThresholdSize
             + AuditTypes.FileSizeT'(AuditTypes.SizeAuditElement)) - 1)
                / AuditTypes.SizeAuditElement);
      end if;

      return LocalSize;

   end TheAlarmThresholdEntries;

end ConfigData;

