#!/bin/bash
# This file is part of sb_pipe.
#
# sb_pipe is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# sb_pipe is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with sb_pipe.  If not, see <http://www.gnu.org/licenses/>.
#
#
# $Revision: 1.0 $
# $Author: Piero Dalle Pezze $
# $Date: 2013-04-20 12:14:32 $

# incremental backup on the Daryl Shanley's cluster. 
# This script is executed by iah-huygens.




# cp -plRu /home/* /media/backup 
# Note: add -z option if transferring on another computer.
printf "\nSynchronisation of the modellers cluster\n"
#rsync -auz --quiet /home/modellers/* /media/backup/
rsync -auz --quiet /home/modellers/* /mnt/iah526_nfs_users_backup/
printf "\nSynchronisation completed\n"
