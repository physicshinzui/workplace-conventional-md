#!/usr/bin/env ruby
require 'fileutils'

# Load environment
ENV['OMP_NUM_THREADS'] = '12'
ENV['GMX'] = 'gmx'
ENV['FF'] = 'ff14SB'
ENV['NTOMP'] = '12'

## If this script is executed on a supercomputer, activate the following lines.
# system('module load intel')
# system('module load impi')
# system('. /etc/profile.d/modules.sh')
# system('source $HOME/miniforge3/bin/activate')
# system('source $HOME/apps/gromacs/2022.5/set_env.sh')

# Get PDB file from arguments
pdb_file = ARGV[0]
unless pdb_file && File.exist?(pdb_file)
  abort("Error: PDB file not found or not provided.")
end

# (1) Create Amber topology and coordinate files
puts "Generating topology files..."
system("pdb4amber -i #{pdb_file} --nohyd -o p4a.pdb")

def create_tleap_input(template, input, ff, output)
  content = File.read(template)
  content.gsub!('#{INPUT}', input)
  content.gsub!('#{FF}', ff)
  File.write(output, content)
end

create_tleap_input('gromacs-inputs/inputs/template_tleap.in', 'p4a.pdb', ENV['FF'], 'tleap.in')
system('tleap -f tleap.in')

# Convert Amber topology and coordinate files to Gromacs ones
system('python scripts/amber2gmx.py system.prmtop system.inpcrd')

# (2) Perform minimisation
def run_gromacs_minimisation(step, input_gro, output_tpr, mdp_file, top_file)
  puts "Energy minimisation #{step} ..."
  system("#{ENV['GMX']} grompp -f #{mdp_file} -c #{input_gro} -p #{top_file} -po mdout_#{step}.mdp -o #{output_tpr} -maxwarn 1")
  system("#{ENV['GMX']} mdrun -deffnm #{step} -ntomp #{ENV['NTOMP']}")
end

run_gromacs_minimisation('em1', 'system.gro', 'em1.tpr', 'templates/em1.mdp', 'system.top')
run_gromacs_minimisation('em2', 'em1.gro', 'em2.tpr', 'templates/em2.mdp', 'system.top')