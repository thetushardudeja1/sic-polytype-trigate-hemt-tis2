* BLIND n-channel prediction (APL 124, 120601): lineup + Au WF from the p-channel calibration, no fit to these curves.
File { Grid="hemt_msh.tdr" Plot="fam_fields.tdr" Current="fam_current.plt" Output="fam_device.log" Parameter="materials.par" }
Electrode {
  { Name="source" Voltage=0 Resist=18200.0 }
  { Name="drain"  Voltage=0 Resist=18200.0 }
  { Name="gate"   Voltage=0 Schottky WorkFunction=5.75 }
}
Physics { Fermi  Temperature=297  Mobility( DopingDependence HighFieldSaturation )  Recombination( SRH( DopingDependence ) )  }
Physics(MaterialInterface="SiliconCarbide/4HSiC") { Thermionic  Traps( FixedCharge Conc=1.48e+13 ) }
Plot { eDensity hDensity Potential ElectricField/Vector ConductionBandEnergy ValenceBandEnergy eQuasiFermi eCurrent/Vector eMobility SpaceCharge }
CurrentPlot { eDensity( Integrate( Semiconductor ) ) }
Math {
  Extrapolate(LowDensityLimit=1e8)
  Derivatives
  RelErrControl
  Digits = 5
  ErrRef(Electron) = 1e4
  ErrRef(Hole) = 1e4
  RhsFactor = 1e30
  RhsMaxQ = 1e60
  CheckRhsAfterUpdate
  ExitOnFailure
  Iterations = 25
  Notdamped = 50
  Method = Blocked SubMethod = Pardiso
  Number_of_Threads = 32
  ParallelLicense( Wait )
}
Solve {
  Coupled(Iterations=1000 LineSearchDamping=1e-4) { Poisson }
  Set( DopingWells(Semiconductor) hQuasiFermi=-30 )
  Coupled(Iterations=1000 LineSearchDamping=1e-4) { Poisson }
  * classical
  Coupled(Iterations=300) { Poisson Electron }
  Plot(FilePrefix="fam_equilibrium")
  Save(FilePrefix="eqsave")
  Load(FilePrefix="eqsave")
  Quasistationary(InitialStep=0.02 MaxStep=0.1 MinStep=1e-6 Increment=1.4 Goal { Name="gate" Voltage=0 } Goal { DopingWells(Semiconductor) hQuasiFermi=-30 }) { Coupled { Poisson Electron } }
  NewCurrentPrefix="famg0_"
  Quasistationary(InitialStep=1e-3 MaxStep=0.02 MinStep=1e-7 Increment=1.4 Goal { Name="drain" Voltage=7 } Goal { DopingWells(Semiconductor) hQuasiFermi=-30 }) {
    Coupled { Poisson Electron }
    CurrentPlot(Time=(Range=(0 1) Intervals=70))
  }
  Plot(FilePrefix="famg0_end")
  Load(FilePrefix="eqsave")
  Quasistationary(InitialStep=0.02 MaxStep=0.1 MinStep=1e-6 Increment=1.4 Goal { Name="gate" Voltage=-1 } Goal { DopingWells(Semiconductor) hQuasiFermi=-30 }) { Coupled { Poisson Electron } }
  NewCurrentPrefix="famg1_"
  Quasistationary(InitialStep=1e-3 MaxStep=0.02 MinStep=1e-7 Increment=1.4 Goal { Name="drain" Voltage=7 } Goal { DopingWells(Semiconductor) hQuasiFermi=-30 }) {
    Coupled { Poisson Electron }
    CurrentPlot(Time=(Range=(0 1) Intervals=70))
  }
  Plot(FilePrefix="famg1_end")
  Load(FilePrefix="eqsave")
  Quasistationary(InitialStep=0.02 MaxStep=0.1 MinStep=1e-6 Increment=1.4 Goal { Name="gate" Voltage=-2 } Goal { DopingWells(Semiconductor) hQuasiFermi=-30 }) { Coupled { Poisson Electron } }
  NewCurrentPrefix="famg2_"
  Quasistationary(InitialStep=1e-3 MaxStep=0.02 MinStep=1e-7 Increment=1.4 Goal { Name="drain" Voltage=7 } Goal { DopingWells(Semiconductor) hQuasiFermi=-30 }) {
    Coupled { Poisson Electron }
    CurrentPlot(Time=(Range=(0 1) Intervals=70))
  }
  Plot(FilePrefix="famg2_end")
  Load(FilePrefix="eqsave")
  Quasistationary(InitialStep=0.02 MaxStep=0.1 MinStep=1e-6 Increment=1.4 Goal { Name="gate" Voltage=-3 } Goal { DopingWells(Semiconductor) hQuasiFermi=-30 }) { Coupled { Poisson Electron } }
  NewCurrentPrefix="famg3_"
  Quasistationary(InitialStep=1e-3 MaxStep=0.02 MinStep=1e-7 Increment=1.4 Goal { Name="drain" Voltage=7 } Goal { DopingWells(Semiconductor) hQuasiFermi=-30 }) {
    Coupled { Poisson Electron }
    CurrentPlot(Time=(Range=(0 1) Intervals=70))
  }
  Plot(FilePrefix="famg3_end")
  Load(FilePrefix="eqsave")
  Quasistationary(InitialStep=0.02 MaxStep=0.1 MinStep=1e-6 Increment=1.4 Goal { Name="gate" Voltage=-4 } Goal { DopingWells(Semiconductor) hQuasiFermi=-30 }) { Coupled { Poisson Electron } }
  NewCurrentPrefix="famg4_"
  Quasistationary(InitialStep=1e-3 MaxStep=0.02 MinStep=1e-7 Increment=1.4 Goal { Name="drain" Voltage=7 } Goal { DopingWells(Semiconductor) hQuasiFermi=-30 }) {
    Coupled { Poisson Electron }
    CurrentPlot(Time=(Range=(0 1) Intervals=70))
  }
  Plot(FilePrefix="famg4_end")
}
