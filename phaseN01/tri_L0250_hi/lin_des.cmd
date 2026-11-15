* 3D n-channel tri-gate, lin: Vd=7.0 V, gate 0.0 -> -8.0 V. Electrons solved, holes excluded by held hQF. Half fin W=0.08 um: Rc in Ohm = 455000.
File { Grid="dev_msh.tdr" Plot="lin_fields.tdr" Current="lin_current.plt" Output="lin_device.log" Parameter="materials.par" }
Electrode {
  { Name="source" Voltage=0 Resist=455000 }
  { Name="drain"  Voltage=0 Resist=455000 }
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
  Number_of_Threads = 32
  ParallelLicense( Wait )
}
Solve {
  Coupled(Iterations=1000 LineSearchDamping=1e-8) { Poisson }
  Set( DopingWells(Semiconductor) hQuasiFermi=-30 )
  Coupled(Iterations=1000 LineSearchDamping=1e-8) { Poisson }
  Coupled(Iterations=200) { Poisson Electron }
  Plot(FilePrefix="lin_eq")
  Quasistationary(InitialStep=0.01 Increment=1.35 Decrement=4 MinStep=1e-6 MaxStep=0.2 Goal { Name="drain" Voltage=7.0 } Goal { DopingWells(Semiconductor) hQuasiFermi=-30 }) { Coupled { Poisson Electron } }
  Plot(FilePrefix="lin_on")
  NewCurrentPrefix="idvg_"
  Quasistationary(InitialStep=1e-3 Increment=1.25 Decrement=4 MinStep=1e-6 MaxStep=0.02 Goal { Name="gate" Voltage=-8.0 } Goal { DopingWells(Semiconductor) hQuasiFermi=-30 }) {
    Coupled { Poisson Electron }
    CurrentPlot(Time=(Range=(0 1) Intervals=100))
  }
  Plot(FilePrefix="lin_off")
}
