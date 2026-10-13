<?php

namespace App\Observers;

use App\Models\Member;

class MemberObserver
{
    public function saved(Member $member): void
    {
        // Role changes must be visible immediately.
        $member->user?->clearCache();
    }

    public function deleted(Member $member): void
    {
        $member->user?->clearCache();
    }
}
