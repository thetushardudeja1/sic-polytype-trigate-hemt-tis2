* AC extension: original calibrated physics; common-source two-port extracted from full 3-terminal matrix.
File { Grid="dev_msh.tdr" Plot="ac_fields.tdr" Current="ac_current.plt" Output="ac_device.log" Parameter="materials.par" ACExtract="admittance" }
Electrode {
  { Name="source" Voltage=0 Resist=18200 }
  { Name="drain"  Voltage=0 Resist=18200 }
  { Name="gate"   Voltage=0 WorkFunction=5.1 }
}
Physics { Fermi  Temperature=297  Mobility( DopingDependence HighFieldSaturation )  Recombination( SRH( DopingDependence ) ) }
Physics(MaterialInterface="SiliconCarbide/4HSiC") { Thermionic  Traps( FixedCharge Conc=1.48e+13 ) }
Plot { eDensity hDensity Potential ElectricField/Vector ConductionBandEnergy eQuasiFermi eCurrent/Vector eMobility SpaceCharge }
CurrentPlot { eDensity( Integrate( Semiconductor ) ) }
Math {
  eMobilityAveraging = ElementEdge
  hMobilityAveraging = ElementEdge
  ParallelToInterfaceInBoundaryLayer( FullLayer -ExternalBoundary )
  ComputeGradQuasiFermiAtContacts = UseQuasiFermi
  WeightedVoronoiBox
  Extrapolate(LowDensityLimit=1e8)
  Derivatives
  RelErrControl
  Digits = 5
  ErrRef(Electron) = 1e8
  ErrRef(Hole) = 1e8
  eDrForceRefDens = 1e8
  hDrForceRefDens = 1e8
  RhsMin = 1e-15
  RhsFactor = 1e30
  RhsMaxQ = 1e60
  Iterations = 10
  Notdamped = 100
  CNormPrint
  ExitOnFailure
  Method = Blocked SubMethod = ParDiSo(IterativeRefinement)
  ACMethod = Blocked
  ACSubMethod = ParDiSo(IterativeRefinement)
  ImplicitACSystem
  Number_of_Threads = 32
  ParallelLicense( Wait )
}
Solve {
  Coupled(Iterations=1000 LineSearchDamping=1e-8) { Poisson }
  Set( DopingWells(Semiconductor) hQuasiFermi=-30 )
  Coupled(Iterations=1000 LineSearchDamping=1e-8) { Poisson }
  Coupled(Iterations=200) { Poisson Electron }
  Quasistationary(InitialStep=0.01 Increment=1.35 Decrement=4 MinStep=1e-6 MaxStep=0.2
    Goal { Name="drain" Voltage=7 }
    Goal { DopingWells(Semiconductor) hQuasiFermi=-30 }) { Coupled { Poisson Electron } }
  Quasistationary(InitialStep=0.01 Increment=1.25 Decrement=4 MinStep=1e-6 MaxStep=0.2
    Goal { Name="gate" Voltage=-5.378329698 }
    Goal { DopingWells(Semiconductor) hQuasiFermi=-30 }) { Coupled { Poisson Electron } }
  Save(FilePrefix="bias")
  Plot(FilePrefix="bias_fields")
  ACCoupled(StartFrequency=1e6 EndFrequency=1e12 NumberOfPoints=61 Decade Node(gate drain source) Exclude(gate drain source)) { Poisson Electron }
}
