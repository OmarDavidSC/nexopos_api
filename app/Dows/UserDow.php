<?php

namespace App\Dows;

use App\Middlewares\Application;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;
use App\Models\Area;
use App\Models\Role;
use App\Models\User;

class UserDow
{

    public function index($request)
    {
        $response = FG::responseDefault();

        try {

            $input = $request->getParsedBody();

            $page = isset($input['page']) ? (int)$input['page'] : 1;
            $perPage = 10;

            $company_id = Application::getItem('company_id');

            $query = User::select('users.*', 'roles.id as role_id', 'roles.name as role_name', 'branches.id as branch_id', 'branches.name as branch_name')
                ->join('user_company_role', 'users.id', '=', 'user_company_role.user_id')
                ->leftJoin('roles', 'user_company_role.role_id', '=', 'roles.id')
                ->leftJoin('branches', 'user_company_role.branch_id', '=', 'branches.id')
                ->where('user_company_role.company_id', $company_id)
                ->where('roles.name', '!=', 'Soporte')
                ->whereNull('users.deleted_at')
                ->orderBy('users.id', 'desc');

            $total = $query->count();

            $users = $query
                ->skip(($page - 1) * $perPage)
                ->take($perPage)
                ->get();

            $data = $users->map(function ($item) {
                return [
                    'id' => $item->id,
                    'name' => $item->name,
                    'paternal_surname' => $item->paternal_surname,
                    'maternal_surname' => $item->maternal_surname,
                    'username' => $item->username,
                    'email' => $item->email,
                    'role_id' => $item->role_id,
                    'role_name' => $item->role_name,
                    'branch_id' => $item->branch_id,
                    'branch_name' => $item->branch_name,
                    'status' => $item->status == 1,
                    'status_label' => $item->status == 1 ? 'Activo' : 'Inactivo',
                    'datecreated_label' => FG::formatDateTimeHuman($item->created_at),
                    'dateupdated_label' => FG::formatDateTimeHuman($item->updated_at),
                ];
            });

            $response['success'] = true;
            $response['data'] = [
                'page' => $page,
                'per_page' => $perPage,
                'total' => $total,
                'total_pages' => ceil($total / $perPage),
                'data' => $data,
            ];

            $response['message'] = 'successfully';
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return $response;
    }

    public function adm($request)
    {
        $response = FG::responseDefault();

        try {
            $company_id = Application::getItem('company_id');

            $areas = User::select('users.*')
                ->join('user_company_role', 'users.id', '=', 'user_company_role.user_id')
                ->where('user_company_role.company_id', $company_id)
                ->whereNull('users.deleted_at')
                ->orderBy('users.name', 'asc')
                ->get();

            $areas = $areas->map(function ($item) {
                return [
                    'id' => $item->id,
                    'name' => $item->name
                ];
            });

            $response['success'] = true;
            $response['data'] = $areas;
            $response['message'] = 'adm';
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return $response;
    }

    public function store($request)
    {
        $response = FG::responseDefault();
        try {
            $input = $request->getParsedBody();
            $company_id = Application::getItem('company_id');

            $name = trim($input['name']);
            $paternal_surname = trim($input['paternal_surname']);
            $maternal_surname = trim($input['maternal_surname']);
            $username = trim($input['username']);
            $email = trim($input['email']);
            $password = trim($input['password']);
            $role_id = trim($input['role_id']);
            $branch_id = trim($input['branch_id']);


            if (empty($name) || empty($username) || empty($email) || empty($password) || empty($role_id)) {
                $response['success'] = false;
                $response['message'] = "Campos Obligatorios!";
                return $response;
            }

            if (User::where('username', $username)->exists()) {
                throw new \Exception("El nombre de usuario ya existe.");
            }

            if (User::where('email', $email)->exists()) {
                throw new \Exception("El correo electrónico ya existe.");
            }

            DB::beginTransaction();

            $user = new User();
            $user->name = $name;
            $user->paternal_surname = $paternal_surname;
            $user->maternal_surname = $maternal_surname;
            $user->username = $username;
            $user->email = $email;
            $user->password = password_hash($password, PASSWORD_DEFAULT);
            $user->status = 1;
            $user->save();

            DB::table('user_company_role')->insert(['user_id' => $user->id, 'company_id' => $company_id, 'branch_id' => $branch_id, 'role_id' => $role_id]);
            DB::commit();

            $response['success'] = true;
            $response['data'] = $user;
            $response['message'] = 'Usuario creado correctamente!.';
        } catch (\Exception $e) {
            DB::rollBack();
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function update($request)
    {
        $response = FG::responseDefault();
        try {
            $id = $request->getAttribute('id');
            $input = $request->getParsedBody();
            $company_id = Application::getItem('company_id');

            $user = User::find($id);
            if (!$user) {
                $response['success'] = false;
                $response['message'] = "Usuario no fue encontrado!.";
                return $response;
            }

            $name = trim($input['name']);
            $paternal_surname = trim($input['paternal_surname']);
            $maternal_surname = trim($input['maternal_surname']);
            $username = trim($input['username']);
            $email = trim($input['email']);
            $role_id = trim($input['role_id']);
            $branch_id = trim($input['branch_id']);

            if (empty($name) || empty($email) || empty($role_id) ||  empty($branch_id)) {
                $response['success'] = false;
                $response['message'] = "Complete los campos obligatorios!";
                return $response;
            }

            if (User::where('username', $username)->where('id', '!=', $id)->exists()) {
                throw new \Exception("El nombre de usuario ya existe.");
            }

            if (User::where('email', $email)->where('id', '!=', $id)->exists()) {
                throw new \Exception("El correo electrónico ya existe.");
            }

            DB::beginTransaction();

            $user->name = $name;
            $user->paternal_surname = $paternal_surname;
            $user->maternal_surname = $maternal_surname;
            $user->username = $username;
            $user->email = $email;
            $user->save();

            DB::table('user_company_role')->where('user_id', $id)->where('company_id', $company_id)->update(['role_id' => $role_id, 'branch_id' => $branch_id]);
            DB::commit();

            $response['success'] = true;
            $response['data'] = $user;
            $response['message'] = "Usuario actualizado correctamente!.";
        } catch (\Exception $e) {
            DB::rollBack();
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function remove($request)
    {
        $response = FG::responseDefault();
        try {
            $id = $request->getAttribute('id');

            $user = User::find($id);
            if (!$user) {
                $response['success'] = false;
                $response['message'] = "Usuario no fue encontrado.";
                return $response;
            }

            $user->deleted_at = FG::getDateHour();
            $user->save();

            $response['success'] = true;
            $response['data'] = $user;
            $response['message'] = "Usuario eliminado correctamente.";
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function role($request)
    {
        $response = FG::responseDefault();
        try {
            $input = $request->getParsedBody();

            $company_id = Application::getItem('company_id');

            $roles = Role::whereNull('deleted_at')
                ->where('name', '!=', 'Soporte')
                ->orderBy('name', 'asc')
                ->get();

            $roles = $roles->map(function ($item) {
                return [
                    'id' => $item->id,
                    'name' => $item->name,
                ];
            });

            $response['success'] = true;
            $response['data'] = $roles;
            $response['message'] = 'role';
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return $response;
    }
}
