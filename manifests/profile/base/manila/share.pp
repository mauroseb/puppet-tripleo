# Copyright 2016 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: tripleo::profile::base::manila::share
#
# Manila share profile for tripleo
#
# === Parameters
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to hiera('step')
#
class tripleo::profile::base::manila::share (
  $step = hiera('step'),
) {
  include ::tripleo::profile::base::manila

  if $step >= 4 {
    include ::manila::share
    $cephfs_auth_id = hiera('manila::backend::cephfsnative::cephfs_auth_id')
    $keyring_path = "/etc/ceph/ceph.client.${cephfs_auth_id}.keyring"
    exec{ "exec-setfacl-${cephfs_auth_id}":
      path    => ['/bin', '/usr/bin' ],
      command => "setfacl -m u:manila:r-- ${keyring_path}",
      unless  => "getfacl ${keyring_path} | grep -q user:manila:r--",
    }
    Ceph::Key<| title == "client.${cephfs_auth_id}" |> -> Exec["exec-setfacl-${cephfs_auth_id}"]

  }
}
