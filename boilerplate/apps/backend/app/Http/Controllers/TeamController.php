<?php

namespace App\Http\Controllers;

use App\Http\Resources\MemberResource;
use App\Http\Resources\TeamResource;
use App\Models\Team;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class TeamController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        abort_unless(request()->user()->isAdmin(), 403, 'You cannot list teams.');

        return TeamResource::collection(Team::with('setting')->latest()->get());
    }

    public function show(): TeamResource
    {
        $team = request()->user()->activeTeam()->firstOrFail();

        return TeamResource::make($team->load('setting'));
    }

    public function store(): JsonResponse
    {
        abort_unless(request()->user()->may(\App\Enums\Feature::TEAM, \App\Enums\Action::CREATE), 403, 'You cannot create teams.');

        $team = Team::create(request()->validate([
            'name' => ['required', 'string', 'max:255'],
            'group' => ['required', new \Illuminate\Validation\Rule\Enum(\App\Enums\Group::class)],
        ]));

        return TeamResource::make($team->fresh()->load('setting'))
            ->response()
            ->setStatusCode(JsonResponse::HTTP_CREATED);
    }

    public function update(Team $team): TeamResource
    {
        abort_unless(request()->user()->may(\App\Enums\Feature::TEAM, \App\Enums\Action::UPDATE), 403, 'You cannot update this team.');

        $team->update(request()->validate([
            'name' => ['sometimes', 'string', 'max:255'],
        ]));

        return TeamResource::make($team->fresh()->load('setting'));
    }

    public function destroy(Team $team): \Illuminate\Http\Response
    {
        abort_unless(request()->user()->may(\App\Enums\Feature::TEAM, \App\Enums\Action::DELETE), 403, 'You cannot delete this team.');

        $team->delete();

        return response()->noContent();
    }

    public function members(Team $team): AnonymousResourceCollection
    {
        abort_unless(request()->user()->may(\App\Enums\Feature::USER, \App\Enums\Action::INDEX), 403, 'You cannot list members.');

        return MemberResource::collection($team->members()->with('user')->get());
    }
}
