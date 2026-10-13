<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Media;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Storage;

class MediaController extends Controller
{
    public function store(): JsonResponse
    {
        $request = request();

        abort_unless($request->user()->may(\App\Enums\Feature::MEDIA, \App\Enums\Action::CREATE), 403, 'You cannot upload media.');

        $file = $request->file('file');
        abort_unless($file, 422, 'No file provided.');

        $path = $file->store(sprintf('%s/%s', $request->user()->uuid, now()->format('Y/m')), 's3');

        $media = Media::create([
            'user_id' => $request->user()->id,
            'disk' => 's3',
            'path' => $path,
            'name' => $file->getClientOriginalName(),
            'mime' => $file->getMimeType(),
            'size' => $file->getSize(),
        ]);

        return response()->json([
            'data' => [
                'id' => $media->uuid,
                'url' => Storage::disk('s3')->url($path),
                'name' => $media->name,
            ],
        ], JsonResponse::HTTP_CREATED);
    }

    public function destroy(Media $media): Response
    {
        abort_unless(request()->user()->may(\App\Enums\Feature::MEDIA, \App\Enums\Action::DELETE), 403, 'You cannot delete media.');

        Storage::disk($media->disk)->delete($media->path);
        $media->delete();

        return response()->noContent();
    }
}
